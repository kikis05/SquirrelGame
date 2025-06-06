# Credit to Bitlytic's Finite State Machine in Godot 4.0 for helping with fundamentals
# https://www.youtube.com/watch?v=ow_Lum-Agbs

extends State
class_name Idle_State

@export var enemy: CharacterBody2D
var move_direction: Vector2

func enter():
	enemy.change_animation("idle")

func physics_process(_delta: float):
	pass
