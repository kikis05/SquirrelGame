extends Area2D

@export var force = 1.0
@export var damage = 20

const SLASH = preload("res://slash.tscn")

@onready var marker_2d = $Marker2D
@onready var slash_speed_timer = $slashSpeedTimer

#original scales of x and y
var SCALE_X = scale.x
var SCALE_Y = scale.y

var canSlash = true

func _ready():
	slash_speed_timer.wait_time = 1.0 /force
	
func attack():
	if canSlash:
		canSlash = false
		slash_speed_timer.start()
		
		var slash_dir = Vector2(Input.get_axis("attack_left", "attack_right"), Input.get_axis("attack_up", "attack_down"))
		if slash_dir.length() > 0:
			slash_dir = slash_dir.normalized()
			
		var rot = rad_to_deg(global_position.angle_to_point(global_position + slash_dir)) 
		if scale.x == -1 * SCALE_X:
			rotation_degrees = -1 * (180 - rot)
		else:
			rotation_degrees = rot
		var slashNode = SLASH.instantiate()
		slashNode.set_direction(slash_dir)
		get_tree().root.add_child(slashNode)
		slashNode.global_position = marker_2d.global_position

#for some reason can't attack until bullet is gone
func _on_slash_speed_timer_timeout() -> void:
	canSlash = true 
	rotation_degrees = 0
	
func set_direction(direction):
	if direction[0] != 0:
		if direction.x < 0:	
			scale.x = SCALE_X * -1
		if direction.x > 0:
			scale.x = SCALE_X * 1
		
func set_damage(damage_):
	damage = damage_ 
	
func is_attacking():
	return (Input.is_action_pressed("attack_down")
	 or Input.is_action_pressed("attack_up")
	 or Input.is_action_pressed("attack_left") 
	 or Input.is_action_pressed("attack_right"))
	
func get_damage():
	#if is_attacking():
		#return damage
	#else: return 0
	return damage
