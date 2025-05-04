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

const ATTACK_THRESHOLD = 2
const HANDS = ["left_hand", "right_hand"]
const AFTER_RIGHT_HAND = ["left_hand", "pheromones"]
const AFTER_LEFT_HAND = ["right_hand", "pheromones"]
const SPAWN = ["spawn_ants", "spawn_fire_ants"]

var idle_count = 0
var hand_just_used = "left"
var attack_set = HANDS
var soldier_count = 0

var last_bullet = null

@onready var anim_tree: AnimationTree
@onready var mod_anim_player: AnimationPlayer


func _ready():
	anim_tree = $AnimationTree
	mod_anim_player = $ModulateAnimPlayer
	randomize() # may be unnecessary?

func _input(_event):
	if Input.is_action_just_pressed("test"):
		take_damage(null)

# ------------- STATE-RELATED -------------
func increase_idle_count():
	idle_count += 1
	
	if idle_count >= ATTACK_THRESHOLD:
		idle_count = 0
		attack()
	### Look at 14min to see when he's calling it

func attack():
	var next_attack = attack_set.pick_random()
	anim_tree.set_condition(next_attack, true)
	if next_attack == "left_hand":
		attack_set = AFTER_LEFT_HAND
	elif next_attack == "right_hand":
		attack_set = AFTER_RIGHT_HAND
	elif next_attack == "pheromones":
		attack_set = SPAWN
	elif next_attack == "spawn_ants" || next_attack == "spawn_fire_ants":
		attack_set = HANDS
	else:
		attack_set = HANDS
	print(attack)
	### Look at 19:24 for how to set condition to false

# ---------- HEALTH & SLIGHT INVINCIBILITY ----------
func take_damage(bullet):
	if bullet != null and last_bullet == bullet: # No double damage for our player
		return 
	else:
		mod_anim_player.play("RESET")
		mod_anim_player.play("Damaged")



func give_damage(): #?
	pass 
