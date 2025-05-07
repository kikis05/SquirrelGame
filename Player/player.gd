extends CharacterBody2D
class_name Player

@export var original_speed = 100
var speed = original_speed
@export_range(0.0, 1.0) var friction = 0.25
@export_range(0.0 , 1.0) var acceleration = 0.3

#health
@export var max_health: int = 6 #2 * number of acorns
var current_health = max_health
signal health_changed

var reset_time = 0.1
#coins
var coins = 0
signal coins_changed
#current weapon
@onready var weapon = get_node("Gun")
@onready var _sfx_hit  : AudioStreamPlayer2D = $HitSFX
@onready var _sfx_coin : AudioStreamPlayer2D = $CoinSFX
@onready var _sfx_death : AudioStreamPlayer2D = $DeathSFX

#animation
@onready var sprite = $AnimatedSprite2D
@onready var invincible_timer = $InvincibleTimer
var flipped = false
var invincible = false
var dead = false

@onready var hitbox = $PlayerHitBox

#Canvas Layers
@onready var health_container = $CanvasLayer/HealthContainer
@onready var coins_container = $CanvasLayer/CoinsContainer
@onready var menu = $CanvasLayer/Menu
@onready var game_over = $"CanvasLayer/Game Over"

#list of available ranged and melee weapons
#can change selection method later
var ranged_weapons = ["Gun"]
var ranged_weapon_choice = 0
var melee_weapons = ["Sword"]
var melee_weapon_choice = 0
var selected_weapon_type = "RANGED"

@onready var powerup_text = $CanvasLayer/Label
@onready var powerup_timer = $PowerupTextTimer

var shop_open = false

func _ready():
	sprite.play("idle")
	menu.hide()
	game_over.hide()
	powerup_text.hide()
	health_container.setMaxAcorns(max_health / 2)
	health_container.updateHealth(current_health)
	health_changed.connect(health_container.updateHealth)

	coins_container.update_coins(coins)
	coins_changed.connect(coins_container.update_coins)
	
	hitbox.speed = speed
	hitbox.coins = coins
	

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
		_sfx_death.play()
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
	
	if movement_dir != Vector2.ZERO:
		sprite.play("run")
	else:
		sprite.play("idle")
	
	if (!shop_open):
		move_and_slide()

func flip():
	sprite.flip_h = !sprite.flip_h
	$Gun.position.x = -1 * $Gun.position.x
	$Gun.flip()
	$Sword.flipped = !$Sword.flipped
	flipped = !flipped
		
func set_weapon(weapon_):
	weapon = weapon_

func _on_player_hit_box_area_entered(area):
	print("player area", area.name)
	if area.is_in_group("coin"):
		_sfx_coin.play() 
		coins += 1
		coins_changed.emit(coins)

func get_max_health():
	if max_health % 2 != 0:
		max_health += 1 #make sure health is even, could instead do error message later
		
	return max_health
	
func get_health():
	return current_health
func set_health(health):
	if powerup_text:
		powerup_text.show()
		powerup_text.text = "Health +" + str(health - current_health)
		powerup_timer.start()
	current_health = min(max_health, health)
	health_changed.emit(current_health) 
	
	
func get_speed():
	return speed
func set_speed(new_speed):
	if powerup_text:
		powerup_text.show()
		powerup_text.text = "Speed +" + str(new_speed - speed)
		powerup_timer.start()
		hitbox.speed = speed
	speed = new_speed
	
func get_coins():
	return coins
func set_coins(cns):
	coins = cns
	coins_changed.emit(coins)
	if hitbox:
		hitbox.coins = coins

func damage_player():
	if invincible == false:
		invincible = true
		current_health -=1
		health_changed.emit(current_health)
		_sfx_hit.play()
		invincible_timer.start()
	sprite.modulate = "red"
	await get_tree().create_timer(reset_time).timeout
	sprite.modulate = Color(1, 1, 1) # White

func _on_invincible_timer_timeout():
	print("meep")
	invincible = false
	# TODO: Will be replaced by an animation

func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation == "death":
		game_over.show()
		dead = true
		
		get_tree().call_group("enemy", "player_has_died")
	
	
func get_sword_attack():
	#note: need to directly access damage variable!!
	return $Sword.damage
	
func set_sword_attack(attack):
	if powerup_text:
		powerup_text.show()
		powerup_text.text = "Sword Attack +" + str(attack - get_sword_attack())
		powerup_timer.start()
	$Sword.set_damage(attack)
	
func get_gun_attack():
	return $Gun.get_bullet_damage()
func set_gun_attack(attack):
	if powerup_text:
		powerup_text.show()
		powerup_text.text = "Sap Attack +" + str(attack - get_gun_attack())
		powerup_timer.start()
	$Gun.set_bullet_damage(attack)
	
func get_gun_speed():
	return $Gun.get_bullet_speed()
func set_gun_speed(spd):
	if powerup_text:
		powerup_text.show()
		powerup_text.text = "Sap Shooter Speed +" + str(spd - get_gun_speed())
		powerup_timer.start()
	$Gun.set_bullet_speed(spd)
	
func reset():
	dead = false
	current_health = max_health
	coins = 0
	speed = original_speed
	$Gun.reset()
	$Sword.reset()

func _on_powerup_text_timer_timeout() -> void:
	powerup_text.hide()
