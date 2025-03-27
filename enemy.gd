extends Area2D
	
@export var health = 50
	
func _on_area_entered(area: Area2D) -> void:
	#One problem, if hit by sword,
	# only the same amount of damage as slash
	print("entered")
	if (area.damage):
		health -= area.get_damage()
		print(health)
	if (health <= 0):
		queue_free()
