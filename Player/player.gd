extends CharacterBody2D
class_name Player

@export var speed = 150
@export_range(0.0, 1.0) var friction = 0.25
@export_range(0.0 , 1.0) var acceleration = 0.3

#health
@export var max_health: int = 6 #2 * number of acorns
var current_health = max_health
signal health_changed
#coins
var coins = 0
signal coins_changed
#current weapon
@onready var weapon = get_node("Gun")

#animation
@onready var sprite = $AnimatedSprite2D
@onready var invincible_timer = $InvincibleTimer
var flipped = false
var invincible = false
var dead = false



#list of available ranged and melee weapons
#can change selection method later
var ranged_weapons = ["Gun"]
var ranged_weapon_choice = 0
var melee_weapons = ["Sword"]
var melee_weapon_choice = 0
var selected_weapon_type = "RANGED"

func _ready():
	sprite.play("idle")

func _input(event):
	#attack toggle
	if event.is_action_pressed("attack_toggle"):
		weapon.hide()
		if selected_weapon_type == "MELEE":
			selected_weapon_type = "RANGED"		
			weapon = get_node(ranged_weapons[ranged_weapon_choice])
		else:
			selected_weapon_type = "MELEE"
			weapon = get_node(melee_weapons[melee_weapon_choice])
			
		weapon.show()		


func _physics_process(_delta):
	if current_health <= 0 and dead == false:
		sprite.play("death")
		return # stop taking player inputs when the player dies
	elif dead == true: # stop taking player inputs when the player dies
		return

	if (Input.is_action_pressed("attack_right")
	 or Input.is_action_pressed("attack_left")
	 or Input.is_action_pressed("attack_down")
	 or Input.is_action_pressed("attack_up")):
		weapon.attack()
	
	var movement_dir = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down"))
	
	if movement_dir.length() > 0:
		movement_dir = movement_dir.normalized()

	#weapon.set_direction(movement_dir)
	# horizontal movement
	if movement_dir[0] != 0:
		velocity.x = lerp(velocity.x, movement_dir[0] * speed, acceleration)
	else:
		velocity.x = lerp(velocity.x, 0.0, friction)
	if (velocity.x > 0) and not flipped:
		flip()
	if (velocity.x < 0) and flipped:
		flip()
	if ((Input.is_action_pressed("attack_left") and velocity.x > 0)
	 or (Input.is_action_pressed("attack_right") and velocity.x < 0)):
		#velocity.x = -1 * velocity.x
		flip()
	# vertical movement
	if movement_dir[1] != 0:
		velocity.y = lerp(velocity.y, movement_dir[1] * speed, acceleration)
	else:
		velocity.y = lerp(velocity.y, 0.0, friction)
	
	move_and_slide()

func flip():
	sprite.flip_h = !sprite.flip_h
	$Gun.position.x = -1 * $Gun.position.x
	$Sword.flipped = !$Sword.flipped
	flipped = !flipped
		
func set_weapon(weapon_):
	weapon = weapon_

func _on_player_hit_box_area_entered(area):
	print("player area", area.name)
	if area.is_in_group("coin"):
		coins += 1
		coins_changed.emit(coins)

func get_max_health():
	if max_health % 2 != 0:
		max_health += 1 #make sure health is even, could instead do error message later
		
	return max_health
	
func get_health():
	return current_health
	
func get_coins():
	return coins

func damage_player():
	if invincible == false:
		invincible = true
		current_health -=1
		health_changed.emit(current_health)
		invincible_timer.start()

func _on_invincible_timer_timeout():
	print("meep")
	invincible = false
	# TODO: Will be replaced by an animation

func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation == "death":
		dead = true
