extends AntEnemy
class_name MosquitoEnemy

var enemy_body: CharacterBody2D
var angular_speed = 4 * PI

func _ready():
	health = 15
	accel = 0.3 
	friction = 0.25
	idle_speed = 12.0
	chase_speed = 40
	knockback_str = 70.0
	
	stunned = false
	attacking = false
	flipped = false

	player = get_tree().get_first_node_in_group("player")
	print(player)
	if velocity.x > 0:
		sprite.flip_h = true
		flipped = true
	
	# different node placement because of the rotating arm
	sprite = $EnemyBody/AnimatedSprite2D
	attack_box = $EnemyBody/AttackBox
	state_machine = $"State Machine"
	enemy_body = $EnemyBody


func _physics_process(delta):
	# sprite flipping
	if velocity.x > 0 and !flipped:
		flip()
	elif velocity.x < 0 and flipped:
		flip()
	
	# rotation of everything and counter-rotation of sprite
	if (stunned == false and attacking == false) and health > 0:
		var new_rotation = rotation + angular_speed * delta
		rotation = lerp(rotation, fmod(new_rotation, (2 * PI)), accel) # NOTE
		enemy_body.rotation = -1 * rotation

func die():
	change_animation("death")
	
	# Different hitbox locations (from the ant) due to the rotation method
	var hit_box: Area2D = $EnemyBody/HitBox
	attack_box.monitoring = false
	hit_box.monitoring = false

func player_has_died():
	state_machine.transition_to("idle state")
	attack_box.monitoring = false
	angular_speed = 0

func flip():
	attack_box.position.x = -1 * attack_box.position.x
	sprite.flip_h = !sprite.flip_h
	flipped = !flipped

func get_nav_agent():
	# no nav agent
	return null


func spawn_babies():
	pass

func stop_moving():
	angular_speed = 0

func start_moving():
	angular_speed = 4 * PI

func _on_hit_box_area_entered(area):
	print(area.name)
	if area.is_in_group("player_weapon") and health > 0:
		if ('get_damage' in area and area.hitbox_activated):
			take_damage(area.get_damage())
			print("Health down to: ", health )
			state_machine.transition_to("stun state")

func _on_attack_box_body_entered(body):
	if body.is_in_group("player") and health > 0:
		if state_machine.current_state.name.to_lower() != "escape state":
			state_machine.transition_to("attack state")
		player_in_range = true

func _on_attack_box_body_exited(body):
	if body.is_in_group("player") and health > 0:
		if state_machine.current_state.name.to_lower() != "escape state":
			state_machine.transition_to("linear chase state")
		player_in_range = false

func _on_animated_sprite_2d_animation_finished():
	if sprite.animation == "death":
		var coin = COIN.instantiate()
		coin.global_position = global_position
		get_tree().root.add_child(coin)
		queue_free()
	elif sprite.animation == "after escape":
		spawn_babies()
		state_machine.transition_to("linear chase state")
	elif sprite.animation == "attack" and player_in_range:
		if player != null and player.dead == false:
			player.damage_player()
			sprite.play("chase")
			state_machine.transition_to("escape state")
		else:
			state_machine.transition_to("idle state") # player is dead, become idle
