extends State
class_name Linear_Chase_State

@export var enemy: CharacterBody2D
var player: CharacterBody2D

func _ready():
	player = get_tree().get_first_node_in_group("player")

func enter():
	enemy.change_animation("chase")

func exit():
	enemy.velocity = Vector2.ZERO 
	enemy.move_and_slide()

func physics_process(_delta: float):
	if player != null: 
		var dir = (player.global_position - enemy.global_position).normalized()
		enemy.velocity = lerp(enemy.velocity, dir * enemy.chase_speed, enemy.accel)
	enemy.move_and_slide()
