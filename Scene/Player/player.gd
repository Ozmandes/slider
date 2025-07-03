extends CharacterBody2D

@export var player_id: bool = true
@onready var velocity_component = %VelocityComponent
@onready var inspecter = %Inspecter

@onready var body = %Body
@onready var head = %Head
@onready var hit = %Hit

@onready var body_material_1 = preload("res://Scene/Player/body1.tres")
@onready var body_material_2 = preload("res://Scene/Player/body2.tres")

@onready var head_material_1 = preload("res://Scene/Player/head1.tres")
@onready var head_material_2 = preload("res://Scene/Player/head2.tres")

@onready var hit_material_1 = preload("res://Scene/Player/hit1.tres")
@onready var hit_material_2 = preload("res://Scene/Player/hit2.tres")

signal player_die


func _ready():
	if player_id:
		body.process_material = body_material_1
		head.process_material = head_material_1
		hit.process_material = hit_material_1
	else:
		body.process_material = body_material_2
		head.process_material = head_material_2
		hit.process_material = hit_material_2


func _process(_delta):
	var movement_vector = get_movement_vector()
	var direction = movement_vector.normalized()
	
	velocity_component.accelerate_in_direction(direction)
	velocity_component.move(self)
	
	if velocity == Vector2.ZERO:
		return
	
	head.position = velocity.normalized() * Vector2(32, 32)
	head.rotation = velocity.angle() + PI/2


func get_movement_vector():
	var movement_vector = Vector2.ZERO
	var x_movement: float
	var y_movement: float
	
	if player_id:
		x_movement = Input.get_action_strength("move_right1") - Input.get_action_strength("move_left1")
		y_movement = Input.get_action_strength("move_down1") - Input.get_action_strength("move_up1")
	else:
		x_movement = Input.get_action_strength("move_right2") - Input.get_action_strength("move_left2")
		y_movement = Input.get_action_strength("move_down2") - Input.get_action_strength("move_up2")
	
	movement_vector = Vector2(x_movement, y_movement)
	
	return movement_vector


func show_hit():
	hit.restart()


func die():
	inspecter.monitoring = false
	
	body.emitting = false
	head.emitting = false
	
	player_die.emit(player_id, self.global_position)
	
	var tween_in = create_tween()
	tween_in.tween_property(Engine, "time_scale", 0.2, 0.2)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	await tween_in.finished
	var tween_out = create_tween()
	tween_out.tween_property(Engine, "time_scale", 1.0, 0.2)\
	.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	
	await tween_out.finished
	self.queue_free()
