# Credit to Bitlytic's Finite State Machine in Godot 4.0 for helping with fundamentals
# https://www.youtube.com/watch?v=ow_Lum-Agbs

extends State
class_name Chase_State

@export var enemy: CharacterBody2D
@onready var nav_agent: NavigationAgent2D
@onready var timer: Timer
var player: CharacterBody2D

func _ready():
	nav_agent = enemy.get_nav_agent()
	
	timer = Timer.new()
	timer.wait_time = 0.3
	timer.one_shot = false
	timer.timeout.connect(on_timer_timeout)
	add_child(timer)

func enter():
	print(enemy.health)
	player = get_tree().get_first_node_in_group("player")
	enemy.change_animation("chase")
	timer.start()

func exit():
	timer.stop()
	nav_agent.target_position = enemy.global_position

func physics_process(_delta: float):
	if nav_agent != null:
		var dir = enemy.to_local(nav_agent.get_next_path_position()).normalized()
		enemy.velocity = lerp(enemy.velocity, dir * enemy.chase_speed, enemy.accel)
	enemy.move_and_slide()

func on_timer_timeout():
	make_path()

func make_path():
	nav_agent.target_position = player.global_position
