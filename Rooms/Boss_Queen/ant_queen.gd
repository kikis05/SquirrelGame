extends Node

"""
- Every 2 Idle Animations, Attack
- Smack down with either hand is the default
	- 50% chance to smack down with the other hand
	- 50% chance to bring in one of its pheromone attacks that shrink room
- Spawn ant / fire ant enemies after pheromone attack
	- will not wait for ants to die before smacking, but will not spawn more until they are gone
	^ first we'll see if this is a problem
- Dead when 0 health
"""

signal spawn_soldiers(type: String)

const ATTACK_THRESHOLD = 2
const HANDS = ["left_hand", "right_hand"]
const AFTER_RIGHT_HAND = ["left_hand", "spawn_ants"]
const AFTER_LEFT_HAND = ["right_hand", "spawn_ants"]
const AFTER_ANTS = ["left_hand", "right_hand", "spawn_fire_ants"]
#const AFTER_RIGHT_HAND = ["left_hand", "pheromones"]
#const AFTER_LEFT_HAND = ["right_hand", "pheromones"]
const SPAWN = ["spawn_ants", "spawn_fire_ants"]

var idle_count = 0
var hand_just_used = "left"
var attack_set = HANDS

var last_bullets = []

@onready var anim_tree: AnimationTree
@onready var mod_anim_player: AnimationPlayer
@onready var health_bar: ProgressBar


func _ready():
	anim_tree = $AnimationTree
	mod_anim_player = $ModulateAnimPlayer
	health_bar = $CanvasLayer/ProgressBar
	health_bar.value = 100.0
	randomize() # may be unnecessary?

# ------------- STATE-RELATED -------------
func increase_idle_count():
	idle_count += 1
	
	if idle_count > ATTACK_THRESHOLD:
		idle_count = 0
		attack()
		return

func attack():
	if health_bar.value <= 0.0: # TODO: Temporarily Queen will just idle after death
		return

	var next_attack = attack_set.pick_random() # next possible attacks switch
	anim_tree.set_condition(next_attack, true)
	if next_attack == "left_hand":
		attack_set = AFTER_LEFT_HAND
	elif next_attack == "right_hand":
		attack_set = AFTER_RIGHT_HAND
	#elif next_attack == "pheromones":
		#attack_set = SPAWN
	elif next_attack == "spawn_ants":
		spawn_soldiers.emit("ants")
		attack_set = AFTER_ANTS
	elif next_attack == "spawn_fire_ants":
		spawn_soldiers.emit("fire_ants")
		attack_set = HANDS
	else:
		attack_set = HANDS

# ------------- HEALTH RELATED ----------------
func take_damage(bullet):
	if bullet != null and bullet in last_bullets: # No double damage for our player
		return 
	else:
		last_bullets.append(bullet)
		if len(last_bullets) > 5:
			last_bullets.pop_front()
		mod_anim_player.play("RESET")
		mod_anim_player.play("Damaged")
		health_bar.value = health_bar.value - bullet.get_damage()
		if health_bar.value <= 0.0:
			die()

func die():
	var head_animation: AnimatedSprite2D = $Node2D/Head/AnimatedSprite2D
	head_animation.play("death")
	anim_tree.set_condition("death", true)

# ----------- INTERACTING WITH PLAYER -------------
func _on_area_2d_body_entered(body):
	var player = get_tree().get_first_node_in_group("player")
	if body.is_in_group("player") \
	and health_bar.value > 0.0 \
	and player != null \
	and player.dead == false:
		player.damage_player()

func _on_center_area_2d_area_entered(area): # bullet hits the center collision shape
	if area.is_in_group("player_weapon") and health_bar.value > 0.0:
		if "get_damage" in area and area.hitbox_activated:
			take_damage(area)
