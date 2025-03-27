extends CharacterBody2D

@export var speed = 150
@export_range(0.0, 1.0) var friction = 0.25
@export_range(0.0 , 1.0) var acceleration = 0.3

#we can later add a selector for weapon type
#Change to $Gun to test Gun and change visibility in editor
@onready var WEAPON = $Gun

func _ready():
	pass

func _physics_process(delta):
	
	if (Input.is_action_pressed("attack_right")
	 or Input.is_action_pressed("attack_left")
	 or Input.is_action_pressed("attack_down")
	 or Input.is_action_pressed("attack_up")):
		WEAPON.attack()
	
	var movement_dir = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down"))
	
	if movement_dir.length() > 0:
		movement_dir = movement_dir.normalized()

	WEAPON.set_direction(movement_dir)
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

		
