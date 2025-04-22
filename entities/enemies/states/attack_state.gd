extends State
class_name Attack_State

@export var enemy: CharacterBody2D
var timer: Timer

func _ready():
	timer = Timer.new()
	timer.wait_time = 1
	timer.one_shot = true
	timer.autostart = false
	timer.timeout.connect(on_timer_finished)
	add_child(timer)

func enter():
	timer.start()
	enemy.set_velocity(Vector2.ZERO)
	enemy.attacking = true
	print(enemy.attacking, enemy.name, "enter")
	enemy.change_animation("attack")

func exit():
	timer.stop()
	enemy.attacking = false
	print(enemy.attacking, enemy.name, "exit")

func on_timer_finished():
	transitioned.emit(self, "attack state")

func physics_process(_delta):
	pass
