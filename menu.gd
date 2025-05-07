extends Control

@onready var sword_attack = $"VBoxContainer/Sword Attack"
@onready var speed = $VBoxContainer/Speed
@onready var health = $VBoxContainer/Health
@onready var sap_attack = $"VBoxContainer/Sap Shooter Attack"
@onready var sap_speed = $"VBoxContainer/Sap Shooter Speed"

@onready var player = get_tree().get_first_node_in_group("player")
func resume():
	get_tree().paused = false
	hide()
	
func pause ():
	show()
	health.text = "Health: " + str(player.get_health())
	speed.text = "Speed: " + str(player.speed)
	sword_attack.text = "Sword Attack: " + str(player.get_sword_attack())
	sap_attack.text = "Sap Attack: " +str(player.get_gun_attack())
	sap_speed.text = "Sap Speed: " +str(player.get_gun_speed())
	get_tree().paused = true
	
func _physics_process(_delta):
	if Input.is_action_just_pressed("Escape") and get_tree().paused == false and not player.shop_open:
		print("here")
		pause()
	elif  Input.is_action_just_pressed("Escape") and get_tree().paused == false and not player.shop_open:
		print("unpaused")
		resume()
		
func _on_resume_pressed() -> void:
	resume()


func _on_exit_pressed() -> void:
	get_tree().quit()
