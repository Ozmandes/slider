extends Node2D

@export var player_scene: PackedScene
@export var pause_menu_scene: PackedScene
@export var change_scene_scene: PackedScene

@onready var time_component = %TimeComponent
@onready var enemy_component = %EnemyComponent
@onready var players = %Players
@onready var respawn_timer = %RespawnTimer
@onready var respawn_time_information = %RespawnTimeInformation
@onready var back_ground = %BackGround
@onready var player_1_score = %Player1Score
@onready var player_2_score = %Player2Score
@onready var time_count = %TimeCount
@onready var game_over = %GameOver
@onready var score_bottom = %ScoreBottom
@onready var score_distance = %ScoreDistance
@onready var firework = %Firework

var player_1_instance: Node2D
var player_2_instance: Node2D
var count_flag: bool = false
var game_over_flag: bool = false

var player_1_score_num: int = 0
var player_2_score_num: int = 0

var time_count_num: int = 0
var game_mode: bool = false # pure mode

signal mode
signal player_score_changed


func _ready():
	add_player(true)
	add_player(false)
	
	respawn_time_information.visible = false
	
	player_score_changed.connect(on_player_score_changed)
	mode.connect(on_mode_select)
	time_component.add_one_second.connect(on_add_one_second)
	time_component.gameover.connect(on_game_over)


func _process(_delta):
	if game_mode:
		update_count_down()
	
	if not count_flag:
		return
	
	respawn_time_information.text = "%.1f" % [respawn_timer.time_left]


func on_mode_select(select_mode: String, time_count_para: int):
	if select_mode == "timing":
		game_mode = true
	
	time_component.choose_game_mode(game_mode, time_count_para)
	enemy_component.set_up(game_mode)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func add_player(player_id: bool):
	if player_id:
		player_1_instance = player_scene.instantiate()
		player_1_instance.global_position = Vector2(360, 360)
		player_1_instance.player_id = true
		players.add_child(player_1_instance)
		player_1_instance.player_die.connect(on_player_die)
	else:
		player_2_instance = player_scene.instantiate()
		player_2_instance.global_position = Vector2(920, 360)
		player_2_instance.player_id = false
		players.add_child(player_2_instance)
		player_2_instance.player_die.connect(on_player_die)


func _input(event):
	if event.is_action_pressed("pause"):
		if game_over_flag:
			return
		
		var pause_menu_instance = pause_menu_scene.instantiate() as CanvasLayer
		self.add_child(pause_menu_instance)
	
	if event.is_action_pressed("exit"):
		exit()


func exit():
	Engine.time_scale = 1
	get_tree().paused = false
	var change_scene_instance = change_scene_scene.instantiate() as CanvasLayer
	get_tree().root.add_child(change_scene_instance)
	
	await change_scene_instance.change_scene_ready
	get_tree().change_scene_to_file("res://Scene/UI/main_menu.tscn")


func on_player_score_changed(count: int, player_id: bool):
	if player_id:
		player_1_score_num += count
		player_1_score_num = max(player_1_score_num, 0)
		player_1_score.text = "[center][wave freq=50 amp=80]%d" % [player_1_score_num]
		await get_tree().create_timer(0.1).timeout
		player_1_score.text = "[center]%d" % [player_1_score_num]
	else:
		player_2_score_num += count
		player_2_score_num = max(player_2_score_num, 0)
		player_2_score.text = "[center][wave freq=50 amp=80]%d" % [player_2_score_num]
		await get_tree().create_timer(0.1).timeout
		player_2_score.text = "[center]%d" % [player_2_score_num]
		

func die_effect(player_position):
	var tween_zoom_in = create_tween()
	tween_zoom_in.parallel().tween_property(back_ground, "scale", Vector2(2.0, 2.0), 0.4)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_zoom_in.parallel().tween_property(back_ground, "offset", -player_position, 0.4)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	await tween_zoom_in.finished
	var tween_zoom_out =create_tween()
	tween_zoom_out.parallel().tween_property(back_ground, "scale", Vector2(1.0, 1.0), 0.4)\
	.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween_zoom_out.parallel().tween_property(back_ground, "offset", Vector2.ZERO, 0.4)\
	.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)



func on_player_die(player_id, player_position):
	die_effect(player_position)
	
	if player_id:
		respawn_time_information.add_theme_color_override("font_color", Color(1, 0.18, 0.198))
	else:
		respawn_time_information.add_theme_color_override("font_color", Color(0, 0.62, 0.736))
	
	var tween_show = create_tween()
	tween_show.tween_property(respawn_time_information, "scale", Vector2(0, 0), 0)
	respawn_time_information.visible = true
	tween_show.tween_property(respawn_time_information, "scale", Vector2(1.4, 1.4), 0.2)
	tween_show.tween_property(respawn_time_information, "scale", Vector2(1, 1), 0.1)
	
	count_flag = true
	
	respawn_timer.start()
	
	await respawn_timer.timeout
	
	var tween_hide = create_tween()
	tween_hide.tween_property(respawn_time_information, "scale", Vector2(1.2, 1.2), 0.1)
	tween_hide.tween_property(respawn_time_information, "scale", Vector2(1, 1), 0.2)
	
	await tween_hide.finished
	respawn_time_information.visible = false
	
	add_player(player_id)


func on_add_one_second():
	time_count_num += 1
	@warning_ignore("integer_division")
	var minute: int = (time_count_num / 60)
	var second: int = time_count_num % 60
	
	time_count.text = "%d:%02d" % [minute, second]


func update_count_down():
	var minute: int = (time_component.left_time / 60)
	var second: int = time_component.left_time % 60
	
	time_count.text = "%d:%02d" % [minute, second]


func on_game_over():
	game_over_flag = true
	respawn_time_information.visible = false
	
	firework.emitting = true
	
	var tween_game_over = create_tween().chain()
	game_over.visible = true
	tween_game_over.tween_property(game_over, "scale", Vector2(0, 0), 0)
	tween_game_over.tween_property(game_over, "scale", Vector2(1.4, 1.4), 0.2)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_game_over.tween_property(game_over, "scale", Vector2(1, 1), 0.1)\
	.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	
	var tween_score_bottom_in = create_tween()
	tween_score_bottom_in.tween_property(score_bottom, "scale", Vector2(1.2, 1.2), 0.2)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_score_bottom_in.tween_property(score_bottom, "scale", Vector2(0, 0), 0.4)\
	.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	
	await tween_score_bottom_in.finished
	score_bottom.add_theme_constant_override("margin_bottom", 256)
	score_distance.add_theme_constant_override("separation", 180)
	
	var tween_score_bottom_out = create_tween()
	tween_score_bottom_out.tween_property(score_bottom, "scale", Vector2(1.2, 1.2), 0.2)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_score_bottom_out.tween_property(score_bottom, "scale", Vector2(1, 1), 0.1)\
	.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	
	var tween_time = create_tween().chain()
	tween_time.tween_property(Engine, "time_scale", 0.2, 0.4)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	await tween_time.finished
	get_tree().paused = true
	Engine.time_scale = 1
	
	await get_tree().create_timer(4).timeout
	exit()
