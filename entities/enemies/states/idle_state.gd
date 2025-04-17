# Credit to Bitlytic's Finite State Machine in Godot 4.0 for helping with fundamentals
# https://www.youtube.com/watch?v=ow_Lum-Agbs

extends State
class_name Idle_State

@export var enemy: CharacterBody2D
var player: CharacterBody2D
var move_direction: Vector2
var wander_time: float

func randomize_wander():
	move_direction = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized()
	wander_time = randf_range(1, 3)

func enter():
	player = get_tree().get_first_node_in_group("player")
	enemy.change_animation("idle")
	randomize_wander()

func update(delta: float):
	if wander_time > 0:
		wander_time -= delta
	else:
		randomize_wander()

func physics_process(_delta: float):
	if enemy != null:
		enemy.velocity = lerp(enemy.velocity, move_direction * enemy.idle_speed, enemy.accel)
	
	var direction = player.global_position - enemy.global_position
	if direction.length() < enemy.detection_radius:
		transitioned.emit(self, "chase state")
