extends Node

@export var enemy_scene: PackedScene

@onready var timer = %Timer
@onready var player_1_score = %Player1Score
@onready var player_2_score = %Player2Score
@onready var time_component = %TimeComponent


func _ready():
	timer.timeout.connect(on_add_enemy)
	time_component.gameover.connect(on_gameover)
	

func set_up(game_mode: bool):
	if game_mode:
		timer.start(randf()+1)


func on_gameover():
	timer.stop()
	
	var enemies: Array = get_tree().get_first_node_in_group("enemies").get_children()
	
	for enemy in enemies:
		enemy.die()


func on_add_enemy():
	var enemy_scence_instance = enemy_scene.instantiate() as Node2D
	
	var random_x = randf_range(32, 1280-32)
	var random_y = randf_range(96, 720-96)
	
	enemy_scence_instance.global_position = Vector2(random_x, random_y)
	get_tree().get_first_node_in_group("enemies").add_child(enemy_scence_instance)
	
	timer.start(randf()+1)
