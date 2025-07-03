extends Node2D

@onready var out_line = %OutLine
@onready var body = %Body
@onready var collision_shape = %CollisionShape
@onready var life_time = %LifeTime

var die_flag: bool = false


func _ready():
	life_time.timeout.connect(die)
	
	await get_tree().create_timer(1).timeout
	call_deferred("set_able")


func set_disable():
	collision_shape.disabled = true

func set_able():
	collision_shape.disabled = false


func die():
	if die_flag:
		return
	
	die_flag = true
	
	call_deferred("set_disable")
	
	body.emitting = false
	body.speed_scale = 2
	out_line.emitting = false
	out_line.speed_scale = 2
	
	await get_tree().create_timer(2).timeout
	self.queue_free()
