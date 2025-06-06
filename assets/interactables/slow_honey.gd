extends Node2D

class_name slow_honey

@onready var overlap_trigger
var entities = []
var original_speeds = []


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.is_in_group("enemy"):
		entities.push_back(body)
		original_speeds.push_back(body.get_speed())
		body.set_speed(50)


func _on_area_2d_body_exited(body: Node2D) -> void:
	for i in range(len(entities)):
		if entities[i] == body:
			if (original_speeds[i] != 50):
				body.set_speed(original_speeds[i])
			else:
				body.set_speed(100) #worst case scenario
		entities.remove_at(i)
		original_speeds.remove_at(i)
		return
		
