# Credit to Bitlytic's Finite State Machine in Godot 4.0 for helping with fundamentals
# https://www.youtube.com/watch?v=ow_Lum-Agbs

extends State
class_name Death_State

@export var enemy: CharacterBody2D

const COIN = preload("res://coin.tscn")

func enter():
	var coin = COIN.instantiate()
	coin.global_position = enemy.global_position
	get_tree().root.add_child(coin)
	enemy.die()

func physics_process(_delta):
	pass
