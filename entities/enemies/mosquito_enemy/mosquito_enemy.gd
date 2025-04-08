extends BaseEnemy

@onready var enemy_body: Node = $"Enemy Body"

@onready var state_machine: Node = $"State Machine"
var knockback = Vector2.ZERO
var player = null
var angular_speed = PI

func _init():
	health = 3
	stunned = false
	idle_speed = 12.0
	chase_speed = 30.0
	knockback_strength = 100.0
	
	detection_radius = 150
	in_range_radius = 20

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	if stunned:
		print("wheeee")
		velocity = knockback
		knockback = lerp(knockback, Vector2.ZERO, 0.1)
	elif !stunned and health == 0: # last stun just finished 
		die()
		### UPDATE TEMP -- CHANGE FOR ACTUAL DEATH
	elif !stunned:
		var new_rotation = rotation + angular_speed * delta
		rotation = fmod(new_rotation, (2 * PI))
		enemy_body.rotation = -1 * rotation
	move_and_slide()

func take_damage(damage):
	health -= damage

func die():
	# play death animation
	queue_free() # UPDATE TEMP

func _on_hit_box_area_entered(area):
	if area.name == "Bullet":
		take_damage(1)
		var direction = -(player.global_position - global_position).normalized()
		knockback = direction * knockback_strength
		state_machine.transition_to("stun state") # updates stunned based on state

func _on_attack_box_body_entered(body):
	if body.name == "Player":
		state_machine.transition_to("attack state")
