extends CharacterBody2D
class_name shop

@onready var modal = $ShopModal

var modal_open = false

var player_in_range = false

var player = null

static var time_entered = 0

func _ready():
	modal.hide()
	time_entered = -1
	pass
		
func _process(delta : float) -> void:
	if (Input.is_action_just_pressed("interact")) and player_in_range:
		print("action pressed")
		#print(time_entered)
		if not modal_open:
			time_entered += 1
			print("base time entered", time_entered)
			modal.show()
			modal_open = true
			modal.set_time_entered(time_entered)
			modal.reopen()
		else:
			modal.hide()
			modal_open = false
	
func _on_activation_area_area_entered(area: Area2D) -> void:
	
	if area.is_in_group("player"):
		if player == null:
			player = get_tree().get_first_node_in_group("player")
			modal.player = player
		player_in_range = true

func _on_activation_area_area_exited(area: Area2D) -> void:
	if area.is_in_group("player"):
		player_in_range = false
	modal.hide()

func _init():
	pass
