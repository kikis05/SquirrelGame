extends AntEnemy
class_name MosquitoBabyEnemy

var enemy_body: CharacterBody2D
var angular_speed = 4 * PI

func _ready():
	health = 1
	accel = 0.3 
	friction = 0.25
	idle_speed = 12.0
	chase_speed = randf_range(50, 70)
	knockback_str = 110
	
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
	if (stunned == false and attacking == false) and health > 0 and player != null:
		var new_rotation = rotation + angular_speed * delta
		rotation = lerp(rotation, fmod(new_rotation, (2 * PI)), accel) # NOTE
		enemy_body.rotation = -1 * rotation

func die():
	emit_signal("enemy_defeated")
	_remove_from_enemy_group_recursive(self)
	await get_tree().process_frame
	await get_tree().process_frame
	for e in get_tree().get_nodes_in_group("enemy"):
		print("🧾 Still in 'enemy' group:", e.name)
	change_animation("death")
	
	# Different hitbox locations (from the ant) due to the rotation method
	var hit_box: Area2D = $EnemyBody/HitBox
	attack_box.monitoring = false
	hit_box.monitoring = false

func flip():
	attack_box.position.x = -1 * attack_box.position.x
	sprite.flip_h = !sprite.flip_h
	flipped = !flipped

func get_nav_agent():
	# no nav agent
	return null

func player_has_died():
	print("HERE")
	state_machine.transition_to("idle state")
	var hit_box: Area2D = $EnemyBody/HitBox
	attack_box.monitoring = false
	hit_box.monitoring = false
	angular_speed = 0

func _on_hit_box_area_entered(area):
	if area.is_in_group("player_weapon") and health > 0 and player.dead == false:
		if ('get_damage' in area and area.hitbox_activated):
			take_damage(area.get_damage())
			print("Health down to: ", health )
			state_machine.transition_to("stun state")

func _on_attack_box_body_entered(body):
	if body.is_in_group("player") and health > 0 and player.dead == false:
		state_machine.transition_to("attack state")
		player_in_range = true

func _on_attack_box_body_exited(body):
	if body.is_in_group("player") and health > 0 and player.dead == false:
		state_machine.transition_to("linear chase state")
		player_in_range = false

func _on_animated_sprite_2d_animation_finished():
	if sprite.animation == "death":
		### NOTE: NO coin dropped from baby mosquito
		#var coin = COIN.instantiate()
		#coin.global_position = global_position
		#get_tree().root.add_child(coin)
		#if player != null:
			#coin.attract_to_player(player)
		queue_free()
	elif sprite.animation == "attack" and player_in_range:
		if player != null and player.dead == false:
			player.damage_player()
			sprite.play("idle")
		else:
			state_machine.transition_to("idle state") # player is dead, become idle
			angular_speed = 0
