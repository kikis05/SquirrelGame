extends BaseEnemy
class_name AntEnemy

@onready var state_machine: Node = $"State Machine"
@onready var sprite: AnimatedSprite2D = $"AnimatedSprite2D"
var player_in_range = false

func _init():
	health = 3.0
	accel = 0.3 
	friction = 0.25
	idle_speed = 12.0
	chase_speed = 25
	knockback_str = 100.0
	
	stunned = false
	attacking = false
	flipped = false

	detection_radius = 150
	in_range_radius = 20

func _ready():
	player = get_tree().get_first_node_in_group("player")
	if velocity.x > 0:
		sprite.flip_h = true
		flipped = true
	make_path()

func _physics_process(_delta):
	# sprite flipping
	if velocity.x > 0 and !flipped:
		flip()
	elif velocity.x < 0 and flipped:
		flip()
	move_and_slide()

func take_damage(damage):
	health -= damage

func die():
	change_animation("death")
	var attack_box: Area2D = $"AttackBox"
	var hit_box: Area2D = $"HitBox"
	attack_box.monitoring = false
	hit_box.monitoring = false

func flip():
	var attackbox: Area2D = $"AttackBox"
	attackbox.position.x = -1 * attackbox.position.x
	sprite.flip_h = !sprite.flip_h
	flipped = !flipped

func change_animation(new_anim):
	if sprite != null:
		sprite.play(new_anim)

func get_nav_agent():
	return get_node("NavigationAgent2D")


func _on_hit_box_area_entered(area):
	if area.name.to_lower() == "bullet" and health > 0:
		# ANNA -- print("TODO: Update this with the player weapon so enemy takes proper dmg")
		take_damage(1) # FIX ATTACK == account for weapon type and damage
		state_machine.transition_to("stun state")

func _on_attack_box_body_entered(body):
	if body.name.to_lower() == "player" and health > 0:
		state_machine.transition_to("attack state")
		player_in_range = true

func _on_attack_box_body_exited(body):
	if body.name.to_lower() == "player" and health > 0:
		state_machine.transition_to("chase state")
		player_in_range = false

func _on_animated_sprite_2d_animation_finished():
	if sprite.animation == "death":
		queue_free()
	elif sprite.animation == "attack" and player_in_range:
		# ANNA -- print("TODO: Player takes DMG") # FIX ATTACK == make it so player takes 1 damage when "attack" animation completes
		sprite.play("idle")
