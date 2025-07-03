extends Node2D

@onready var start = %Start
@onready var quit = %Quit
@onready var option = %Option

@export var option_menu_scene: PackedScene
@export var change_scene_scene: PackedScene


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	start.pressed.connect(on_start_pressed)
	quit.pressed.connect(on_quit_pressed)
	option.pressed.connect(on_option_pressed)


func on_start_pressed():
	var change_scene_instance = change_scene_scene.instantiate() as CanvasLayer
	get_tree().root.add_child(change_scene_instance)
	
	await change_scene_instance.change_scene_ready
	get_tree().change_scene_to_file("res://Scene/main.tscn")


func on_quit_pressed():
	get_tree().quit()


func on_option_pressed():
	var change_scene_instance = change_scene_scene.instantiate() as CanvasLayer
	get_tree().root.add_child(change_scene_instance)
	
	await change_scene_instance.change_scene_ready
	var option_menu_instance = option_menu_scene.instantiate() as CanvasLayer
	self.add_child(option_menu_instance)
