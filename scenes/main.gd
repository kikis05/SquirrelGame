extends Node

@onready var health_container = $CanvasLayer/HealthContainer
@onready var player = $Player

func _ready() : 
	health_container.setMaxAcorns(player.get_max_health() / 2 )
	health_container.updateHealth(player.get_health())
	player.health_changed.connect(health_container.updateHealth)
