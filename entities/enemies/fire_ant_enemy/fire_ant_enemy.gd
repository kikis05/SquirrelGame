extends AntEnemy

@export var fire_trail: PackedScene
@export var fire_spawn: Node


func _on_fire_spawn_timer_timeout():
	var fire_inst = fire_trail.instantiate()
	fire_inst.global_position = global_position
	if player != null and player.dead == false:
		fire_inst.player = player
	get_tree().root.add_child(fire_inst)

## NOTE: Functions the are the same as in ant_enemy
## They were reused to properly connect area2d and animsprite2d nodes to script
func _on_hit_box_area_entered(area):
	if area.is_in_group("player_weapon") and health > 0 and player.dead == false:
		if ('get_damage' in area and area.hitbox_activated):
			take_damage(area.get_damage())
			print("Health down to: ", health)
			state_machine.transition_to("stun state")

# TODO: CHECK why player could be null when scene restarts
func _on_attack_box_body_entered(body):
	if body.name.to_lower() == "player" and health > 0:
		if player == null:
			player = body
		if player.dead == false:
			state_machine.transition_to("attack state")
			player_in_range = true
			player.damage_player()

func _on_attack_box_body_exited(body):
	if body.name.to_lower() == "player" and health > 0 and player.dead == false:
		state_machine.transition_to("chase state")
		player_in_range = false

func _on_animated_sprite_2d_animation_finished():
	if sprite.animation == "death":		
		var coin = COIN.instantiate()
		coin.global_position = global_position
		get_tree().root.add_child(coin)
		if player != null:
			coin.attract_to_player(player)
		queue_free()
	elif sprite.animation == "attack" and player_in_range:
		print(player.name)
		if player != null and player.dead == false:
			print("should damage player")
			player.damage_player()
		sprite.play("idle")
