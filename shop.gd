extends CharacterBody2D

@onready var modal = $ShopModal

var modal_open = false

var shop_available = false

func _ready():
	#modal.hide()
	pass
		
func _process(delta : float) -> void:
	if (Input.is_action_just_pressed("shop")) and shop_available:
		print("action pressed")
		if not modal_open:
			modal.show()
			modal_open = true
		else:
			modal.hide()
			modal_open = false
	
func _on_activation_area_area_entered(area: Area2D) -> void:
	print("area entered")
	if area.name.to_lower() == "player":
		shop_available = true

func _on_activation_area_area_exited(area: Area2D) -> void:
	if area.name.to_lower() == "player":
		shop_available = false
	modal.hide()
