extends Node2D

var is_locked = true
var is_closed = true
var player_in_range = false

@export var item = preload("res://Shops/shop_item.tscn")
# @export var item = preload("res://entities/items/upgrade_item.tscn")

@onready var sprite: AnimatedSprite2D = null
@onready var outline: AnimatedSprite2D = null
@onready var label: RichTextLabel = null

func _ready():
	sprite = $AnimatedSprite2D
	outline = $SpriteOutline
	label = $RichTextLabel
	label.text = "LOCKED"
	sprite.play("closed")

func set_chest(new_item):
	if new_item == null: # spawn an opened chest
		is_locked = false
		is_closed = false
		player_in_range = false
		sprite.play("open")
		outline.visible = false
		label.visible = false
	else: 
		item.set_item(new_item)

func _input(event):
	if Input.is_action_just_pressed("interact") and \
	player_in_range and \
	is_locked == false and \
	is_closed == true:
		sprite.play("open")
		is_closed = false
		outline.visible = false
		label.visible = false
		spawn_item()
	elif Input.is_action_just_pressed("test"): # TODO remove when signal implemented
		room_completed() # TODO remove when signal implemented


func room_completed():
	label.text = "E to OPEN"
	is_locked = false
	outline.visible = true

func spawn_item():
	var spawned_item = item.instantiate()
	spawned_item.global_position = $Marker2D.global_position
	get_tree().root.add_child(spawned_item)

func _on_area_2d_area_entered(area):
	if area.is_in_group("player") and is_closed == true:
		if is_locked == true: # room not yet completed
			outline.visible = true # only toggles when chest locked
		label.visible = true
		player_in_range = true

func _on_area_2d_area_exited(area):
	if area.is_in_group("player") and is_closed == true:
		if is_locked == true: # room not yet completed
			outline.visible = false # only toggles when chest locked
		player_in_range = false
		label.visible = false
