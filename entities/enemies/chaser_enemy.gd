extends CharacterBody2D

@export var speed = 100
var chasing_player = false
var player = null


func _physics_process(delta):
	if chasing_player and player != null:
		position += (player.position - position)/speed
	#else:
		#velocity.y = lerp(velocity.y, 0.0, friction)


func _on_area_2d_body_entered(body):
	if body.name == "Player":
		chasing_player = true
		player = body


func _on_area_2d_body_exited(body):
	if body.name == "Player":
		chasing_player = false
		player = null


func _on_damage_area_body_entered(body):
	if body.name == "Player":
		chasing_player = false
		player = null


func _on_damage_area_body_exited(body):
	if body.name == "Player":
		chasing_player = true
		player = body
