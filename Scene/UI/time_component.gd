extends Node

@onready var one_second = %OneSecond
@onready var count_down = %CountDown

var left_time: int = 0
var game_mode_flag: bool = false

signal add_one_second
signal gameover

func _ready():
	one_second.timeout.connect(on_one_second_timeout)
	count_down.timeout.connect(on_count_down)


func _process(_delta):
	if not game_mode_flag:
		return
	
	left_time = floor(count_down.time_left)


func on_one_second_timeout():
	add_one_second.emit()


func on_count_down():
	gameover.emit()


func choose_game_mode(game_mode: bool, time_count: int):
	if not game_mode:
		one_second.start()
	else:
		count_down.start(time_count)
		game_mode_flag = true
