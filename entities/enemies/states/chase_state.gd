extends State
class_name Chase_State

@export var enemy: CharacterBody2D
@onready var nav_agent: NavigationAgent2D
@onready var timer: Timer
var player: CharacterBody2D

func _ready():
	nav_agent = enemy.get_nav_agent()
	
	timer = Timer.new()
	timer.wait_time = 0.5
	timer.one_shot = false
	timer.timeout.connect(on_timer_timeout)
	add_child(timer)
	
	player = get_tree().get_first_node_in_group("player")

func enter():
	make_path()
	enemy.change_animation("chase")
	timer.start()

func exit():
	timer.stop()
	nav_agent.target_position = enemy.global_position
	enemy.set_velocity(Vector2.ZERO)
	enemy.move_and_slide()

func physics_process(_delta: float):
	if nav_agent != null:
		var dir = enemy.to_local(nav_agent.get_next_path_position()).normalized()
		enemy.velocity = lerp(enemy.velocity, dir * enemy.chase_speed, enemy.accel)
	enemy.move_and_slide()

func on_timer_timeout():
	make_path()

func make_path():
	if (player != null and player.dead == false):
		nav_agent.target_position = player.global_position
	else:
		transitioned.emit(self, "idle state")
