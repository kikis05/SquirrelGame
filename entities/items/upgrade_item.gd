extends StaticBody2D

var type = "health"
var player_in_range = false
@onready var sprite: AnimatedSprite2D
@onready var label: RichTextLabel

func _ready():
	label = $RichTextLabel
	sprite = $AnimatedSprite2D
	
	var all_types = []
	for anim in sprite.sprite_frames.get_animation_names():
		all_types.append(anim)
	type = all_types.pick_random()
	
	sprite.play(type)
	label.visible = false

func set_item(new_item: String):
	if new_item in sprite.spriteframes.get_animation_names(): 
		sprite.play(type)
	else:
		return # new item type is not one that exists OR it is mistyped

func _input(event):
	if Input.is_action_just_pressed("interact") and player_in_range:
		#var player = get_tree().get_first_node_in_group("player")
		if type == "health":
			print("TODO: increase max health here")
		elif type == "sword attack":
			print("TODO: increase sword attack here")
		queue_free()

func _on_area_2d_area_entered(area):
	if area.is_in_group("player"):
		label.visible = true
		player_in_range = true


func _on_area_2d_area_exited(area):
	if area.is_in_group("player"):
		label.visible = false
		player_in_range = false
