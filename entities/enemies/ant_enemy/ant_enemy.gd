extends BaseEnemy
class_name AntEnemy

@onready var state_machine: Node = $"State Machine"
@onready var sprite: AnimatedSprite2D = $"AnimatedSprite2D"

var player_in_range = false

var death_location = Vector2.ZERO
const COIN = preload("res://coin.tscn")

func _init():
	health = 10
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
	print(global_position, position)
	if (health <= 0):
		death_location.y = global_position.y - 58
		death_location.x = global_position.x - 153

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
	print(area.name)
	if area.is_in_group("player_weapon") and health > 0:
		if ('get_damage' in area and area.hitbox_activated):
			take_damage(area.get_damage())
			print("Health down to: ", health )
			state_machine.transition_to("stun state")

func _on_attack_box_body_entered(body):
	if body.is_in_group("player") and health > 0:
		state_machine.transition_to("attack state")
		player_in_range = true

func _on_attack_box_body_exited(body):
	if body.is_in_group("player") and health > 0:
		state_machine.transition_to("chase state")
		player_in_range = false

func _on_animated_sprite_2d_animation_finished():
	if sprite.animation == "death":
		var coin = COIN.instantiate()
		print(coin.global_position)
		coin.global_position = death_location
		get_tree().root.add_child(coin)
		queue_free()
	elif sprite.animation == "attack" and player_in_range:
		print(player.name)
		if player != null:
			print("should damage player")
			player.damage_player()
		sprite.play("idle")
