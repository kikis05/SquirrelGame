extends StaticBody2D

var item = ""

var player_in_range = false
@onready var sprite: AnimatedSprite2D
@onready var label: RichTextLabel

func _ready():
	label = $RichTextLabel
	sprite = $AnimatedSprite2D
	
	var all_types = []
	for anim in sprite.sprite_frames.get_animation_names():
		all_types.append(anim)
	item = all_types.pick_random()
	
	sprite.play(item)
	label.visible = false

func set_item(new_item: String):
	if new_item in sprite.spriteframes.get_animation_names(): 
		sprite.play(new_item)
	else:
		return # new item type is not one that exists OR it is mistyped

func _input(event):
	if Input.is_action_just_pressed("interact") and player_in_range:
		#var player = get_tree().get_first_node_in_group("player")
		powerup_player()
		queue_free()
		
	
func powerup_player():
	var player = get_tree().get_first_node_in_group("player")
	match(item):
		"blueberry" : 
			player.set_speed(player.get_speed() + 30)
		"sunflower_seed": 
			player.set_speed(player.get_speed() + 10)
		"thorn":
			player.set_sword_attack(player.get_sword_attack() + 10)
		"pebbles":
			player.set_gun_speed(player.get_gun_speed() + 50)
		"spicy_sap":
			player.set_gun_attack(player.get_gun_attack() + 3)
		#can remove these later
		"sword_attack":
			player.set_sword_attack(player.get_sword_attack() + 10) 
		"health":
			player.set_health(player.get_health() + 1)

func _on_area_2d_area_entered(area):
	if area.is_in_group("player"):
		label.visible = true
		player_in_range = true


func _on_area_2d_area_exited(area):
	if area.is_in_group("player"):
		label.visible = false
		player_in_range = false
