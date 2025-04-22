extends Area2D

func _on_area_entered(area: Area2D) -> void:
	print("overlap", area.name)
	if area.is_in_group("player"):
		queue_free()
