extends BaseEnemy

var state_machine: State_Machine
var sprite: AnimatedSprite2D
var attack_box: Area2D

var player_in_range = false

const COIN = preload("res://coin.tscn")

func _ready():
	health = 10
	accel = 0.3 
	friction = 0.25
	idle_speed = 12.0
	chase_speed = randf_range(35, 65)
	print(chase_speed)
	knockback_str = 100.0
	
	stunned = false
	attacking = false
	flipped = false
	
	state_machine = $"State Machine"
	sprite = $AnimatedSprite2D
	attack_box = $AttackBox
	
	player = get_tree().get_first_node_in_group("player")
	if velocity.x > 0:
		sprite.flip_h = true
		flipped = true

func _physics_process(_delta):
	# sprite flipping
	if velocity.x > 0 and !flipped:
		flip()
	elif velocity.x < 0 and flipped:
		flip()

func take_damage(damage):
	health -= damage

func die():
	change_animation("death")
	
	await sprite.animation_finished
	
	var hit_box: Area2D = $HitBox
	attack_box.monitoring = false
	hit_box.monitoring = false
	super()

func flip():
	attack_box.position.x = -1 * attack_box.position.x
	sprite.flip_h = !sprite.flip_h
	flipped = !flipped

func change_animation(new_anim):
	if sprite == null or (new_anim not in sprite.get_sprite_frames().get_animation_names()):
		return
	else:
		sprite.play(new_anim)

func get_nav_agent():
	var nav_agent: NavigationAgent2D = $NavigationAgent2D
	return nav_agent

func player_has_died():
	state_machine.transition_to("idle state")
	attack_box.monitoring = false


func _on_hit_box_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_weapon") and health > 0:
		# (1) grab the player reference lazily if we don't have it yet
		if player == null:
			player = get_tree().get_first_node_in_group("player")    # or "Player"
		# (2) if it’s still null, bail out
		if player == null or player.dead:
			return

		if "get_damage" in area and area.hitbox_activated and _is_damage_allowed(area): 
			take_damage(area.get_damage())
			print("Health down to:", health)
			state_machine.transition_to("stun state")


func _on_attack_box_body_entered(body):
	if player == null:
		player = get_tree().get_first_node_in_group("player")    # or "Player"
		# (2) if it’s still null, bail out
		if player == null or player.dead:
			return
	if body.is_in_group("player") and health > 0 and player.dead == false:
		state_machine.transition_to("attack state")
		player_in_range = true
		player.damage_player()

func _on_attack_box_body_exited(body):
	if body.is_in_group("player") and health > 0 and player.dead == false:
		state_machine.transition_to("chase state")
		player_in_range = false

func _on_animated_sprite_2d_animation_finished():
	if sprite.animation == "death":
		var coin = COIN.instantiate()
		coin.global_position = global_position
		get_tree().root.add_child(coin)
		if player != null:
			coin.attract_to_player(player)
			
	elif sprite.animation == "attack" and player_in_range:
		if player != null and player.dead == false:
			player.damage_player()
			sprite.play("idle")
		else:
			state_machine.transition_to("idle state") # player is dead, become idle

func _is_damage_allowed(area : Area2D) -> bool:
	if "get_damage_type" in area:
		return area.get_damage_type() == "sword"
	return false
