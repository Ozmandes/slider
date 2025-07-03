extends CanvasLayer

@export var change_scene_scene: PackedScene

@onready var information = %Information
@onready var adjust_time = %AdjustTime
@onready var minus = %Minus
@onready var time = %Time
@onready var plus = %Plus
@onready var timing_mode = %TimingMode
@onready var pure_mode = %PureMode
@onready var start = %Start

var time_count: int = 120
var select_mode: String = "pure"


func _ready():
	get_tree().paused = true
	timing_mode.pressed.connect(on_select_timing_mode)
	pure_mode.pressed.connect(on_select_pure_mode)
	start.pressed.connect(on_start)
	plus.pressed.connect(on_plus_time)
	minus.pressed.connect(on_minus_time)


func update_time():
	@warning_ignore("integer_division")
	var minute: int = time_count / 60
	var second: int = time_count % 60
	
	time.text = "[center][wave freq=50 amp=80]%d:%02d" % [minute, second]
	await get_tree().create_timer(0.1).timeout
	time.text = "[center]%d:%02d" % [minute, second]


func on_select_timing_mode():
	adjust_time.visible = true
	information.text = "Timing mode selected"
	select_mode = "timing"


func on_select_pure_mode():
	adjust_time.visible = false
	information.text = "Pure mode selected"
	select_mode = "pure"


func on_start():
	owner.mode.emit(select_mode, time_count)
	
	var change_scene_instance = change_scene_scene.instantiate() as CanvasLayer
	get_tree().root.add_child(change_scene_instance)
	await change_scene_instance.change_scene_ready
	get_tree().paused = false
	self.queue_free()


func on_plus_time():
	time_count += 30
	update_time()


func on_minus_time():
	time_count = max(0, time_count - 30)
	update_time()
