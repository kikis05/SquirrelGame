# Credit to Bitlytic's Finite State Machine in Godot 4.0 for helping with fundamentals
# https://www.youtube.com/watch?v=ow_Lum-Agbs

extends Node
class_name State

signal transitioned(state: State, new_state_name: String)

func enter():
	pass

func exit():
	pass

func update(_delta: float):
	pass

func physics_update(_delta: float):
	pass
