extends CharacterBody2D
class_name BaseEnemy

## General vars ##
@export var player: Player
@export var health: float
@export var accel: float # acceleration
@export var friction: float
@export var idle_speed: float
@export var chase_speed: float
@export var knockback_str: float # knockback_strength

## State related ##
@export var stunned: bool
@export var attacking: bool
@export var flipped: bool

## Enemy defeated signal ##
signal enemy_defeated

func _ready():
	if not is_in_group("enemy"):
		print("🚨", name, "was not in 'enemy' group — adding it now")
		add_to_group("enemy")

func physics_process(_delta: float):
	pass

func apply_damage(_damage: int, _body: Node):
	pass

func take_damage(_damage: int):
	pass

func make_path():
	pass

func heal(_damage: int):
	pass

func die():
	queue_free()

func emit_death():
	print("🛑 BaseEnemy.die() called — emitting signal and queue_free()")
	emit_signal("enemy_defeated")
	_remove_from_enemy_group_recursive(self)
	await get_tree().process_frame
	await get_tree().process_frame
	for e in get_tree().get_nodes_in_group("enemy"):
		print("🧾 Still in 'enemy' group:", e.name)

func change_animation(_name: String):
	pass

func get_nav_agent():
	pass
func get_speed():
	return chase_speed

func set_speed(spd):
	chase_speed = spd

func start_moving():
	pass

func stop_moving():
	pass

func player_has_died():
	pass
	
func _exit_tree():
	print("💀 Enemy removed from scene tree:", name)

func _remove_from_enemy_group_recursive(node: Node) -> void:
	if node.is_in_group("enemy"):
		node.call_deferred("remove_from_group", "enemy")  # safer with deferred call
	for child in node.get_children():
		_remove_from_enemy_group_recursive(child)

func _is_damage_allowed(area : Area2D) -> bool:
	# By default every enemy accepts every damage type.
	# Sub‑classes can override this for special rules.
	return true
