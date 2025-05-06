extends Area2D

@export var force = 0.5
@export var original_damage = 5
var damage = original_damage

const SLASH = preload("res://slash.tscn")

@onready var marker_2d = $Marker2D
@onready var slash_speed_timer = $slashSpeedTimer
@onready var hitbox = $HitBox
@export var damage_type : String = "melee"

@onready var sprite = $Sprite2D

#original scales of x and y
var SCALE_X = scale.x
var SCALE_Y = scale.y

var hitbox_activated = false

var canSlash = true

var flipped = false
var flipped_v = false

func _ready():
	slash_speed_timer.wait_time = 1.0 /force
	
func attack():
	if canSlash:
		hitbox.show()
		canSlash = false
		slash_speed_timer.start()
		
		var slash_dir = Vector2(Input.get_axis("attack_left", "attack_right"), Input.get_axis("attack_up", "attack_down"))
		if slash_dir.length() > 0:
			slash_dir = slash_dir.normalized()
		if slash_dir.y > 0:
			position.y = 20
			position.x = 0
			sprite.flip_v = !sprite.flip_v
			flipped_v = true
		if slash_dir.y < 0:
			position.y = -15
			position.x = 0
		var slashNode = SLASH.instantiate()
		slashNode.set_direction(slash_dir)
		get_tree().root.add_child(slashNode)
		slashNode.global_position = marker_2d.global_position
		
func _physics_process(_delta: float) -> void: 
	if is_attacking() and canSlash:
		hitbox.show()
		hitbox_activated = true
	elif not is_attacking():
		hitbox.hide()
		hitbox_activated = false
	if not Input.is_action_pressed("attack_down") and not Input.is_action_pressed("attack_up"):
		position.y = 0
		position.x = -15 if not flipped else 15
		if flipped_v:
			sprite.flip_v = !sprite.flip_v
			flipped_v = false
			

#for some reason can't attack until bullet is gone
func _on_slash_speed_timer_timeout() -> void:
	canSlash = true 
	rotation_degrees = 0
	
#func set_direction(direction):
	#if direction[0] != 0:
		#if direction.x < 0:	
		#if direction.x > 0:
		
	
func is_attacking():
	return (Input.is_action_pressed("attack_down")
	 or Input.is_action_pressed("attack_up")
	 or Input.is_action_pressed("attack_left") 
	 or Input.is_action_pressed("attack_right"))
	
func get_damage():
	print("damage requested")
	if hitbox_activated:
		print("sword is attacking")
		return damage
	return 0
func set_damage(dmg):
	damage = dmg 
