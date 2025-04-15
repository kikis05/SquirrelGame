extends BaseEnemy

@onready var state_machine: Node = $"State Machine"
@onready var animatedsprite2d: AnimatedSprite2D = $"AnimatedSprite2D"


func _init():
	health = 3
	accel = 0.3 
	friction = 0.25
	idle_speed = 12.0
	chase_speed = 50.0
	knockback_str = 100.0
	
	stunned = false
	attacking = false
	flipped = false

	detection_radius = 150
	in_range_radius = 20

func _ready():
	player = get_tree().get_first_node_in_group("player")
	if player.position.x > position.x:
		animatedsprite2d.flip_h = true
		flipped = true

func _physics_process(_delta):
	if player.position.x > position.x and !flipped:
		flip()
	elif player.position.x < position.x and flipped:
		flip()
	move_and_slide()

func take_damage(damage):
	health -= damage

func die():
	change_animation("death")

func flip():
	var attackbox: Area2D = $"AttackBox"
	var animatedsprite2d: AnimatedSprite2D = $"AnimatedSprite2D"
	attackbox.position.x = -1 * attackbox.position.x
	animatedsprite2d.flip_h = !animatedsprite2d.flip_h
	flipped = !flipped

func change_animation(name):
	if animatedsprite2d != null:
		animatedsprite2d.play(name)

func _on_hit_box_area_entered(area):
	if area.name.to_lower() == "bullet":
		take_damage(1)
		state_machine.transition_to("stun state") # updates stunned based on state

func _on_attack_box_body_entered(body):
	if body.name.to_lower() == "player":
		state_machine.transition_to("attack state")

func _on_attack_box_body_exited(body):
	if body.name.to_lower() == "player":
		state_machine.transition_to("chase state")

func _on_nav_timer_timeout():
	pass # Replace with function body.

func _on_animated_sprite_2d_animation_finished():
	if animatedsprite2d.animation == "death":
		queue_free()
