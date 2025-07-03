extends CanvasLayer

@onready var pause = %Pause

@export var change_scene_scene: PackedScene

func _ready():
	get_tree().paused = true


func _input(event):
	if event.is_action_pressed("pause"):
		back_to_game()
		get_tree().root.set_input_as_handled()
	
	if event.is_action_pressed("exit"):
		get_tree().root.set_input_as_handled()
		back_to_menu()


func back_to_game():
	get_tree().paused = false
	self.queue_free()


func back_to_menu():
	get_tree().paused = false
	var change_scene_instance = change_scene_scene.instantiate() as CanvasLayer
	get_tree().root.add_child(change_scene_instance)
	
	await change_scene_instance.change_scene_ready
	get_parent().get_tree().change_scene_to_file("res://Scene/UI/main_menu.tscn")
