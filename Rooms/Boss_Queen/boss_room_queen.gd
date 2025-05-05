extends Node2D

@onready var queen = $AntQueen
@export var ant_scene: PackedScene
@export var fire_ant_scene: PackedScene

func _ready():
	queen.spawn_soldiers.connect(spawn_soldiers)

func spawn_soldiers(type):
	# TODO: Test limits, keep in mind that players will have upgrades
	# Unlike me, the tester
	if (get_tree().get_nodes_in_group("enemy").size() >= 8):
		return
		
	if (type == "ants"):
		var markers = $"Land Markers"
		for marker in markers.get_children():
			var ant_enemy = ant_scene.instantiate()
			get_tree().root.add_child(ant_enemy)
			ant_enemy.global_position = marker.global_position
	elif (type == "fire_ants"):
		var markers = $"Land Markers"
		for marker in markers.get_children():
			var fire_ant_enemy = fire_ant_scene.instantiate()
			get_tree().root.add_child(fire_ant_enemy)
			fire_ant_enemy.global_position = marker.global_position
	else:
		return
