extends Area2D

@export var speed = 500
@export var fade = 3 #how fast the slash effect fades
@export var damage = 5
@onready var damage_type = "sword"

@onready var sprite = $Sprite2D

var direction:Vector2

var hitbox_activated = true

func _ready():
	sprite.flip_h = !sprite.flip_h

func set_direction(slashDirection):
	direction = slashDirection
	rotation_degrees = rad_to_deg(global_position.angle_to_point(global_position+direction))
	
func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	sprite.modulate.a -= (delta * fade)
	#print(global_position)
	if (sprite.modulate.a <= 0):
		queue_free()
	
func _on_body_entered(body):
	#Need to create group for enemies
	#if body.is_in_group("enemies"):
	body.die() #not sure what this is
	queue_free()
	
func set_speed(speed_):
	speed = speed_
	
func set_fade(fade_):
	fade = fade_
	
func set_damage(damage_):
	damage = damage_

func get_damage_type():
	return damage_type

func get_damage():
	return damage * sprite.modulate.a
	
