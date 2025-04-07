extends CharacterBody2D

@export var speed = 150
@export_range(0.0, 1.0) var friction = 0.25
@export_range(0.0 , 1.0) var acceleration = 0.3

@export var max_health: int = 6 #2 * number of acorns
var current_health = max_health
signal health_changed
#current weapon
@onready var weapon = get_node("Gun")

#list of available ranged and melee weapons
#can change selection method later
var ranged_weapons = ["Gun"]
var ranged_weapon_choice = 0
var melee_weapons = ["Sword"]
var melee_weapon_choice = 0
var selected_weapon_type = "RANGED"


func _input(event):
	#attack toggle
	if event.is_action_pressed("attack_toggle"):
		weapon.visible = false
		if selected_weapon_type == "MELEE":
			selected_weapon_type = "RANGED"		
			weapon = get_node(ranged_weapons[ranged_weapon_choice])
		else:
			selected_weapon_type = "MELEE"
			weapon = get_node(melee_weapons[melee_weapon_choice])
			
		weapon.visible = true
		

func _ready():
	pass

func _physics_process(delta):
	
	
	if (Input.is_action_pressed("attack_right")
	 or Input.is_action_pressed("attack_left")
	 or Input.is_action_pressed("attack_down")
	 or Input.is_action_pressed("attack_up")):
		weapon.attack()
	
	var movement_dir = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down"))
	
	if movement_dir.length() > 0:
		movement_dir = movement_dir.normalized()

	weapon.set_direction(movement_dir)
	# horizontal movement
	if movement_dir[0] != 0:
		velocity.x = lerp(velocity.x, movement_dir[0] * speed, acceleration)
	else:
		velocity.x = lerp(velocity.x, 0.0, friction)
		
	# vertical movement
	if movement_dir[1] != 0:
		velocity.y = lerp(velocity.y, movement_dir[1] * speed, acceleration)
	else:
		velocity.y = lerp(velocity.y, 0.0, friction)
	
	move_and_slide()

		
func set_weapon(weapon_):
	weapon = weapon_

func _on_hit_box_area_entered(area: Area2D) -> void:
	if area.name == "HitBox": #double check this
		current_health -= 1
		print_debug(current_health)
		health_changed.emit(current_health)
	if current_health <= 0:
		current_health = 0
		queue_free()
		
func get_max_health():
	if max_health % 2 != 0:
		max_health += 1 #make sure health is even, could instead do error message later
		
	return max_health
func get_health():
	return current_health
	
