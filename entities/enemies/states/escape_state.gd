extends State
class_name Escape_State

@export var enemy: CharacterBody2D
var player: CharacterBody2D
var timer: Timer
var still_moving = true

func _ready():
	player = get_tree().get_first_node_in_group("player")
	
	timer = Timer.new()
	timer.wait_time = 1.5
	timer.autostart = false
	timer.one_shot = true
	timer.timeout.connect(on_timer_finished)
	add_child(timer)

func enter():
	enemy.change_animation("chase")
	timer.start()
	still_moving = true

func exit():
	enemy.velocity = Vector2.ZERO 
	enemy.move_and_slide()
	timer.stop()
	still_moving = true
	enemy.start_moving()

func physics_process(_delta: float):
	if still_moving == false:
		enemy.velocity = lerp(enemy.velocity, Vector2.ZERO, enemy.accel)
		enemy.move_and_slide()
	elif player != null:
		var dir = (player.global_position - enemy.global_position).normalized()
		enemy.velocity = lerp(enemy.velocity, -1.5 * dir * enemy.chase_speed, enemy.accel)
		# speedy escape
		enemy.move_and_slide()

func on_timer_finished():
	print("hereeeeeeee")
	enemy.change_animation("after escape") # some form of animation / something that happens after escape
	enemy.stop_moving()
	# ie. for mosquito mother, it is making babies appear
	still_moving = false
