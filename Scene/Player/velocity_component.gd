extends Node

@export var max_speed: int
@export var acceleration: float

var velocity: Vector2 = Vector2.ZERO


func accelerate_in_direction(direction: Vector2, a: float = acceleration):
	var desired_velocity = direction * max_speed
	velocity = velocity.lerp(desired_velocity, 1 - exp(-a * get_process_delta_time()))


func decelerate():
	accelerate_in_direction(Vector2.ZERO)


func pause():
	velocity = Vector2.ZERO

func move(character_body: CharacterBody2D):
	character_body.velocity = velocity
	character_body.move_and_slide()
	velocity = character_body.velocity
