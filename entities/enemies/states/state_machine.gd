# Credit to Bitlytic's Finite State Machine in Godot 4.0 for helping with fundamentals
# https://www.youtube.com/watch?v=ow_Lum-Agbs

extends Node

@export var initial_state: State

var current_state: State
var states: Dictionary = {}

func _ready():
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.transitioned.connect(on_child_transition)
	
	if initial_state != null:
		initial_state.enter()
		current_state = initial_state

func _process(delta):
	if current_state:
		current_state.update(delta)

func _physics_process(delta):
	if current_state:
		current_state.physics_update(delta)

func transition_to(new_state_name):
	on_child_transition(current_state, new_state_name)

func on_child_transition(state, new_state_name):
	if state != current_state:
		return
	
	var new_state = states.get(new_state_name.to_lower())
	if new_state == null:
		return
	
	if current_state != null:
		current_state.exit()
	new_state.enter()
	current_state = new_state
