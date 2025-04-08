extends CharacterBody2D
class_name BaseEnemy

## General vars ##
@export var health: int
@export var stunned: bool
@export var idle_speed: float
@export var chase_speed: float
@export var knockback_strength: float

## Radius vars ##
@export var detection_radius: int # range for chasing player
@export var in_range_radius: int 
# range to be close enough to attack without being on top of the player

func apply_damage(_damage: int, _body: Node):
	pass

func take_damage(damage: int):
	pass

func heal(damage: int):
	pass

func die():
	queue_free()
