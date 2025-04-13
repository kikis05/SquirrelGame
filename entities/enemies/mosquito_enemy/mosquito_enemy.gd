extends BaseEnemy

@onready var enemy_body: Node = $"Enemy Body"

@onready var state_machine: Node = $"State Machine"
var angular_speed = PI
var spinning = true

func _init():
	health = 3
	stunned = false
	accel = 0.3
	friction = 0.25
	idle_speed = 12.0
	chase_speed = 30.0
	knockback_str = 100.0
	
	detection_radius = 150
	in_range_radius = 20

func _physics_process(delta):
	if !stunned and spinning:
		var new_rotation = rotation + angular_speed * delta
		rotation = lerp(rotation, fmod(new_rotation, (2 * PI)), accel) # NOTE
		enemy_body.rotation = -1 * rotation
	move_and_slide()

func take_damage(damage):
	health -= damage

func die():
	# play death animation
	queue_free() # UPDATE TEMP

func _on_hit_box_area_entered(area):
	print("pew")
	if area.name.to_lower() == "bullet":
		take_damage(1)
		state_machine.transition_to("stun state") # updates stunned based on state

func _on_attack_box_body_entered(body):
	print(body.name)
	if body.name.to_lower() == "player":
		state_machine.transition_to("attack state")
		print("beep")
		spinning = false

func _on_attack_box_body_exited(body):
	if body.name.to_lower() == "player":
		state_machine.transition_to("attack state")
		spinning = true
