extends Node2D

@export var shootSpeed = 1.0

const BULLET = preload("res://bullet.tscn")

@onready var marker_2d = $Marker2D
@onready var shoot_speed_timer = $shootSpeedTimer

var canShoot = true

#original scales of x and y
var SCALE_X = scale.x
var SCALE_Y = scale.y

func _ready():
	shoot_speed_timer.wait_time = 1.0 /shootSpeed
	
func attack():
	if canShoot:
		canShoot = false
		shoot_speed_timer.start()
		
		var bullet_dir = Vector2(Input.get_axis("attack_left", "attack_right"), Input.get_axis("attack_up", "attack_down"))
		if bullet_dir.length() > 0:
			bullet_dir = bullet_dir.normalized()
			
		var rot = rad_to_deg(global_position.angle_to_point(global_position + bullet_dir))
		if scale.x == -1 * SCALE_X:
			rotation_degrees = -1 * (180 - rot)
		else:
			rotation_degrees = rot
		var bulletNode = BULLET.instantiate()
		
		bulletNode.set_direction(bullet_dir)
		get_tree().root.add_child(bulletNode)
		bulletNode.global_position = marker_2d.global_position
		bulletNode.destroyTimer.start()

#for some reason can't shoot until bullet is gone
func _on_shoot_speed_timer_timeout():
	canShoot = true 
	rotation_degrees = 0
	
func set_direction(direction):
	if direction[0] != 0:
		if direction.x < 0:
			scale.x = SCALE_X * 1
		if direction.x > 0:
			scale.x = SCALE_X * -1
		
	
