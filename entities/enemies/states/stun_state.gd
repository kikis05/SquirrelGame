# Credit to Bitlytic's Finite State Machine in Godot 4.0 for helping with fundamentals
# https://www.youtube.com/watch?v=ow_Lum-Agbs

extends State
class_name StunState

@export var enemy: CharacterBody2D

var player: CharacterBody2D
var timer: Timer

func enter():
	timer = Timer.new()
	timer.wait_time = 0.7
	timer.autostart = true
	timer.timeout.connect(on_timer_finished)
	add_child(timer)
	enemy.set_velocity(Vector2.ZERO)
	enemy.stunned = true

func exit():
	timer.stop()
	timer.timeout.disconnect(on_timer_finished)
	timer.queue_free()
	timer = null
	enemy.stunned = false

func on_timer_finished():
	transitioned.emit(self, "chase state")
