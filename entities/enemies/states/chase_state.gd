# Credit to Bitlytic's Finite State Machine in Godot 4.0 for helping with fundamentals
# https://www.youtube.com/watch?v=ow_Lum-Agbs

extends State
class_name Chase_State

@export var enemy: CharacterBody2D
var player: CharacterBody2D

func enter():
	player = get_tree().get_first_node_in_group("player")
	enemy.change_animation("chase")

func physics_update(_delta: float):
	var direction = player.global_position - enemy.global_position
	
	if direction.length() > enemy.in_range_radius:
		enemy.velocity = lerp(enemy.velocity, direction.normalized() * enemy.chase_speed, enemy.accel)
	else:
		enemy.velocity = lerp(enemy.velocity, Vector2(), enemy.friction)
