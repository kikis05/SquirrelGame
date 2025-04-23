extends Node

var enemies : Array = []
var doors : Array = []

func _ready():
	# Collect all enemies and doors in this room
	enemies = get_tree().get_nodes_in_group("Enemies")
	doors = get_tree().get_nodes_in_group("Doors")
	for e in enemies:
		e.connect("enemy_defeated", _on_enemy_defeated)
	if enemies.size() > 0:
		for door in doors:
			door.slam_shut()

func _on_enemy_defeated():
	enemies = enemies.filter(func(e): return e.is_inside_tree())
	if enemies.size() == 0:
		for door in doors:
			door.open_door()
