extends CharacterBody2D

@onready var modal = $ShopModal

var modal_open = false

var player_in_range = false

var player = null

func _ready():
	modal.hide()
	pass
		
func _process(delta : float) -> void:
	if (Input.is_action_just_pressed("interact")) and player_in_range:
		print("action pressed")
		if not modal_open:
			modal.show()
			modal_open = true
		else:
			modal.hide()
			modal_open = false
	
func _on_activation_area_area_entered(area: Area2D) -> void:
	print("area entered",)
	
	if area.is_in_group("player"):
		if player == null:
			player = get_tree().get_first_node_in_group("player")
			modal.player = player
		print("player null?", player == null)
		print("player identified")
		player_in_range = true

func _on_activation_area_area_exited(area: Area2D) -> void:
	if area.is_in_group("player"):
		print("player gone")
		player_in_range = false
	modal.hide()
