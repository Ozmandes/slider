extends Area2D


func _ready():
	self.body_entered.connect(on_body_entered)


func on_body_entered(body: Node2D):
	owner.show_hit()
	
	add_score(body)
	
	body.die()


func add_score(body):
	if body is StaticBody2D:
		get_tree().get_first_node_in_group("main").player_score_changed.emit(1, owner.player_id)
	
	if body is CharacterBody2D:
		get_tree().get_first_node_in_group("main").player_score_changed.emit(10, owner.player_id)
