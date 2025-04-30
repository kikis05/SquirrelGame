extends Node2D

@export var shootSpeed = 1.0

@export var original_bullet_speed = 100
var bullet_speed = original_bullet_speed
@export var original_bullet_damage = 15
var bullet_damage = original_bullet_damage

const BULLET = preload("res://bullet.tscn")

@onready var marker_2d = $Marker2D
@onready var shoot_speed_timer = $shootSpeedTimer
@onready var sprite = $Gun_Sprite

var canShoot = true

#original scales of x and y
var SCALE_X = scale.x
var SCALE_Y = scale.y

#flip
var flipped = false


func _ready():
	shoot_speed_timer.wait_time = 1.0 /shootSpeed
	
func attack():
	if canShoot:
		canShoot = false
		shoot_speed_timer.start()
		
		var bullet_dir = Vector2(Input.get_axis("attack_left", "attack_right"), Input.get_axis("attack_up", "attack_down"))
		if bullet_dir.length() > 0:
			bullet_dir = bullet_dir.normalized()
		if bullet_dir.y < 0:
			if flipped:
				rotation_degrees = -90
			else:
				rotation_degrees = 90
		if bullet_dir.y > 0:
			if flipped:
				rotation_degrees = 90
			else:
				rotation_degrees = -90
		if bullet_dir.x > 0 and not flipped:
			flip()
		if bullet_dir.x < 0 and flipped:
			flip()
			
		var bulletNode = BULLET.instantiate()
		bulletNode.set_origin(global_position)
		bulletNode.set_direction(bullet_dir)
		bulletNode.damage = bullet_damage
		bulletNode.speed = bullet_speed
		get_node("/root/Main/DungeonGenerator").current_room_instance.add_child(bulletNode)
		bulletNode.global_position = marker_2d.global_position

func _physics_process(_delta: float) -> void: 
	if not Input.is_action_pressed("attack_down") and not Input.is_action_pressed("attack_up"):
		rotation_degrees = 0

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
		
func flip():
	sprite.flip_h = !sprite.flip_h
	flipped = !flipped
	
# TODO: handle bullet damage linkage to gun damage
func get_bullet_damage():
	return bullet_damage
func set_bullet_damage(dmg):
	bullet_damage = dmg
func get_bullet_speed():
	return bullet_speed 
func set_bullet_speed(spd):
	bullet_speed = spd
