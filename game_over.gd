extends Node2D

	


func _on_exit_pressed() -> void:
	get_tree().quit()
	
func _on_resume_pressed() -> void:
	get_tree().get_first_node_in_group("player").reset()
	get_tree().change_scene_to_file("res://scenes/main.tscn")
