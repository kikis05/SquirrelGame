extends State
class_name Attack_State

@export var enemy: CharacterBody2D
var timer: Timer

func enter():
	timer = Timer.new()
	timer.wait_time = 0.5
	timer.autostart = true
	timer.timeout.connect(on_timer_finished)
	add_child(timer)
	enemy.set_velocity(Vector2.ZERO)
	enemy.stunned = true

func exit():
	timer.queue_free()
	timer = null
	enemy.stunned = false

func on_timer_finished():
	transitioned.emit(self, "chase state")


### TO DO: ADD ACTUAL ATTACKS
