extends Node2D

class_name slow_honey

@onready var overlap_trigger
var entity = null
var original_speed : int


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		entity = body
		original_speed = entity.speed
		entity.speed = 10


func _on_area_2d_body_exited(body: Node2D) -> void:
	if (entity != null):
		entity.speed = original_speed
		entity = null
