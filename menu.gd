extends Control

func resume():
	get_tree().paused = false
	hide()
	
func pause ():
	get_tree().paused = true
	
func handle_escape():
	if Input.is_action_just_pressed("Escape") and get_tree().paused == false:
		print("here")
		pause()
	elif  Input.is_action_just_pressed("Escape") and get_tree().paused == true:
		print("here")
		resume()
		
func _on_resume_pressed() -> void:
	resume()


func _on_exit_pressed() -> void:
	get_tree().quit()
