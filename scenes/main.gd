extends Node

@onready var health_container = $CanvasLayer/HealthContainer
@onready var coins_container = $CanvasLayer/CoinsContainer
@onready var menu = $CanvasLayer/Menu
@onready var player = $Player

func _ready() : 
	menu.hide()
	health_container.setMaxAcorns(player.get_max_health() / 2 )
	health_container.updateHealth(player.get_health())
	player.health_changed.connect(health_container.updateHealth)
#
	coins_container.update_coins(player.get_coins())
	player.coins_changed.connect(coins_container.update_coins)
	
func _process(_delta):
	if Input.is_action_just_pressed("Escape") and get_tree().paused == false:
		menu.show()
		menu.pause()
	elif  Input.is_action_just_pressed("Escape") and get_tree().paused == true:
		menu.hide()
		menu.resume()
