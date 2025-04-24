extends Node

@onready var health_container = $CanvasLayer/HealthContainer
@onready var coins_container = $CanvasLayer/CoinsContainer
@onready var menu = $CanvasLayer/Menu
@onready var dungeon_generator = $DungeonGenerator  # Adjust path if needed

var player : Node = null

func _ready() -> void:
	menu.hide()

	dungeon_generator.player_spawned.connect(_on_player_spawned)
	dungeon_generator.room_loaded.connect(_on_room_loaded)

	dungeon_generator.start_game()


func _on_player_spawned(p: Node) -> void:
	player = p

	# UI bindings
	health_container.setMaxAcorns(player.get_max_health() / 2)
	health_container.updateHealth(player.get_health())
	player.health_changed.connect(health_container.updateHealth)

	coins_container.update_coins(player.get_coins())
	player.coins_changed.connect(coins_container.update_coins)

	# Safe player assignment to enemies
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if "player" in enemy:
			enemy.player = player

func _on_room_loaded():
	# Reassign player to any new enemies that just loaded
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if "player" in enemy:
			enemy.player = player

	
func _process(_delta):
	#if Input.is_action_just_pressed("Escape") and get_tree().paused == false:
		#print("open menu")
		#menu.show()
		#menu.pause()
	#elif  Input.is_action_just_pressed("Escape") and get_tree().paused == true:
		#print("close menu")
		#menu.resume()
		#menu.hide()
		pass
