extends CharacterBody2D
	
@export var health = 50

func _on_hit_box_area_entered(area: Area2D) -> void:
	#One problem, if hit by sword,
	# only the same amount of damage as slash
	print("entered")
	if ('get_damage' in area and area.visible):
		health -= area.get_damage()
	if (health <= 0):
		queue_free()
