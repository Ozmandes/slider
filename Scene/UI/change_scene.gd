extends CanvasLayer

@onready var color_rect = %ColorRect
@onready var timer = %Timer

signal change_scene_ready

func _ready():
	timer.timeout.connect(_hide)
	
	color_rect.modulate = Color(1, 1, 1, 0)
	_show()


func _show():
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate", Color(1, 1, 1, 1), 0.3)\
	.set_ease(Tween.EASE_IN)
	
	await tween.finished
	change_scene_ready.emit()


func _hide():
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate", Color(1, 1, 1, 1), 0)
	tween.tween_property(color_rect, "modulate", Color(1, 1, 1, 0), 0.3)\
	.set_ease(Tween.EASE_OUT)
	
	await tween.finished
	self.queue_free()
