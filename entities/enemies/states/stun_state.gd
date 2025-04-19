# Credit to Bitlytic's Finite State Machine in Godot 4.0 for helping with fundamentals
# https://www.youtube.com/watch?v=ow_Lum-Agbs

extends State
class_name Stun_State

@export var enemy: CharacterBody2D
var timer: Timer
var knockback = Vector2.ZERO
var player: CharacterBody2D


func _ready():
	player = get_tree().get_first_node_in_group("player")
	
	timer = Timer.new()
	timer.wait_time = 0.7
	timer.autostart = false
	timer.one_shot = true
	timer.timeout.connect(on_timer_finished)
	add_child(timer)

func enter():
	# timer determines the length of stun
	enemy.change_animation("stun")
	
	# how far back the enemy flies
	enemy.set_velocity(Vector2.ZERO)
	if player != null:
		var dir = -(player.global_position - enemy.global_position).normalized()
		knockback = dir * enemy.knockback_str
		timer.start()
		enemy.stunned = true

func exit():
	timer.stop()
	enemy.stunned = false

func physics_process(_delta: float):
	if enemy.stunned:
		enemy.velocity = knockback
		knockback = lerp(knockback, Vector2.ZERO, 0.1)
	enemy.move_and_slide()

func on_timer_finished():
	if enemy.health <= 0:
		#var coin = COIN.instantiate()
		#coin.global_position = enemy.global_position
		#get_tree().root.add_child(coin)
		transitioned.emit(self, "death state")
	else:
		transitioned.emit(self, "chase state")
