extends Area2D

@export var speed = 200
@export var damage = 15

@onready var destroyTimer = $DestroyBullet

var direction:Vector2

func set_direction(bulletDirection):
	direction = bulletDirection
	rotation_degrees = rad_to_deg(global_position.angle_to_point(global_position+direction))
	
func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	
func _on_body_entered(body):
	#group for enemies
	#if body.is_in_group("enemies"):
	print("Entered Body")
	body.die() #not sure what this is
	queue_free()

#Delete this once we implement collision with enemy
func _on_destroy_bullet_timeout() -> void:
	queue_free()
	
func set_speed(speed_):
	speed = speed_
	
func set_damage(damage_):
	damage = damage_
func get_damage():
	return damage
