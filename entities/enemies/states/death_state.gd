# Credit to Bitlytic's Finite State Machine in Godot 4.0 for helping with fundamentals
# https://www.youtube.com/watch?v=ow_Lum-Agbs

extends State
class_name Death_State

@export var enemy: CharacterBody2D

func enter():
	enemy.die()
