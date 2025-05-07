extends Node2D

@onready var _door : Door = $DoorW/DoorW
@onready var player : Player = $Player

func _ready() -> void:
	var stats = GameState.player_stats
	player.set_health(stats["current_health"])
	player.set_speed(stats["speed"])
	player.set_coins(stats["coins"])
	player.set_gun_attack(stats["gun_attack"])
	player.set_gun_speed(stats["gun_speed"])
	player.set_sword_attack(stats["sword_attack"])
	_door.slam()
