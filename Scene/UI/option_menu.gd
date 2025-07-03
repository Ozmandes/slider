extends CanvasLayer

@export var change_scene_scene: PackedScene

@onready var window_option = %WindowOption
@onready var audio_option = %AudioOption
@onready var back = %Back

var mute_flag: bool = false


func _ready():
	window_option.pressed.connect(on_window_option_pressed)
	audio_option.pressed.connect(on_audio_option_pressed)
	back.pressed.connect(on_back_pressed)


func _input(event):
	if event.is_action_pressed("pause"):
		get_tree().root.set_input_as_handled()
		on_back_pressed()


func on_window_option_pressed():
	var mode = DisplayServer.window_get_mode()
	if mode != DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		window_option.text = "Fullscreen"
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		window_option.text = "Windowe"


func on_audio_option_pressed():
	mute_flag = not mute_flag
	
	if mute_flag:
		audio_option.text = "Mute Audio"
		MusicPlayer.stream_paused = true
	else:
		audio_option.text = "Normal Audio"
		MusicPlayer.stream_paused = false


func on_back_pressed():
	var change_scene_instance = change_scene_scene.instantiate() as CanvasLayer
	get_tree().root.add_child(change_scene_instance)
	
	await change_scene_instance.change_scene_ready
	get_parent().get_tree().change_scene_to_file("res://Scene/UI/main_menu.tscn")
