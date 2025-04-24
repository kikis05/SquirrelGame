extends Node

@onready var health_container = $CanvasLayer/HealthContainer
@onready var coins_container = $CanvasLayer/CoinsContainer
@onready var menu = $CanvasLayer/Menu
@onready var dungeon_generator = $DungeonGenerator  # Adjust path if needed

var player : Node = null

func _ready() -> void:

	dungeon_generator.player_spawned.connect(_on_player_spawned)
	dungeon_generator.room_loaded.connect(_on_room_loaded)

	dungeon_generator.start_game()


func _on_player_spawned(p: Node) -> void:
	player = p

	# Safe player assignment to enemies
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if "player" in enemy:
			enemy.player = player

func _on_room_loaded():
	# Reassign player to any new enemies that just loaded
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if "player" in enemy:
			enemy.player = player

	
