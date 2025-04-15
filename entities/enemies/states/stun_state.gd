# Credit to Bitlytic's Finite State Machine in Godot 4.0 for helping with fundamentals
# https://www.youtube.com/watch?v=ow_Lum-Agbs

extends State
class_name Stun_State

@export var enemy: CharacterBody2D
var timer: Timer
var knockback = Vector2.ZERO
var player: CharacterBody2D

func enter():
	# timer determines the length of stun
	timer = Timer.new()
	timer.wait_time = 0.7
	timer.autostart = true
	timer.timeout.connect(on_timer_finished)
	add_child(timer)
	player = get_tree().get_first_node_in_group("player")
	
	# how far back the enemy flies
	enemy.set_velocity(Vector2.ZERO)
	var direction = -(player.global_position - enemy.global_position).normalized()
	knockback = direction * enemy.knockback_str
	enemy.stunned = true

func exit():
	timer.queue_free()
	timer = null
	enemy.stunned = false

func physics_update(_delta: float):
	if enemy.stunned:
		enemy.velocity = knockback
		knockback = lerp(knockback, Vector2.ZERO, 0.1)

func on_timer_finished():
	if enemy.health <= 0:
		transitioned.emit(self, "death state")
	else:
		transitioned.emit(self, "chase state")
