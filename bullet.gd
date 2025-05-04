extends Area2D

var speed = 0
var damage = 15

@onready var landingTimer = $DestroyBullet
@onready var fadeTimer = $FadeTimer
@onready var sprite = $AnimatedSprite2D #change to Animation

var fading = 0

var direction:Vector2
var has_landed = false
var origin
var shoot_direction

var hitbox_activated = true

func set_direction(bulletDirection):
	direction = bulletDirection
	rotation_degrees = rad_to_deg(global_position.angle_to_point(global_position+direction))
	
func set_origin(_origin):
	origin = _origin
	
func set_shoot_direction(_shoot_direction):
	shoot_direction = _shoot_direction

func _physics_process(delta: float) -> void:
	if not has_landed:
		global_position += direction * speed * delta
		global_position.y += 1.5 
	else:
		sprite.animation = "land"
		direction = Vector2.ZERO
		sprite.self_modulate.a -= fading * delta
		
	if ((direction.y > 0 and global_position.y >= origin.y + 70)
		or (direction.y < 0 and global_position.y <= origin.y - 70)
			or (direction.x != 0 and global_position.y >= origin.y + 10)):
				has_landed = true
				damage = damage / 2
				landingTimer.start()
	

#Delete this once we implement collision with enemy
func _on_destroy_bullet_timeout() -> void:
	fading = 1
	fadeTimer.start()
	
func _on_fade_timer_timeout() -> void:
	queue_free()
	
func set_speed(speed_):
	speed = speed_
	
func set_damage(damage_):
	damage = damage_
func get_damage():
	return damage


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy") and area.name.to_lower() == "hitbox":
		queue_free()

func destroy():
	queue_free()
