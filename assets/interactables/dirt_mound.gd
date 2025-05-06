extends CharacterBody2D

@onready var sprite = $Sprite2D
@onready var collisions = [$Area2D/CollisionShape2D, $CollisionShape2D]
var stage = 0
	
#func _on_area_2d_body_entered(body: Area2D) -> void:
	#print(body.name, "entered mound")
	#if (body.name.to_lower() == "bullet"):
		#stage += 1
		#sprite.frame = stage
	#if (sprite.frame == 6):
		#collisions[0].hide()
		#collisions[1].hide()
		


func _on_area_2d_area_entered(area: Area2D) -> void:
	print(area.name, "entered mound")
	if (area.name.to_lower() == "bullet"):
		area.destroy()
		stage += 1
		sprite.frame = stage
	if (sprite.frame == 6):
		queue_free()
