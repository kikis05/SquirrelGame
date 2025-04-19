extends CharacterBody2D

@export var sprite: AnimatedSprite2D
@export var player : CharacterBody2D

func _on_timer_timeout():
	sprite.play("death")
	var attack_collision: CollisionShape2D = $"AttackBox/AttackCollisionArea"
	attack_collision.disabled = true
	# ^we don't want players to get hit by a big col shape as the fire dies

func _on_animated_sprite_2d_animation_finished():
	if sprite.animation == "death":
		queue_free()


## TODO: Functions below PAIRED, remove this comment after implementing
func _on_attack_box_body_entered(body):
	if body.name.to_lower() == "player" and player != null:
		# ANNA -- print("TODO: Fire trail player dmg")
		player.damage_player()
		pass

func _on_attack_box_body_exited(body):
	if body.name.to_lower() == "player":
		# ANNA -- print("TODO: Fire trail player dmg")
		pass
