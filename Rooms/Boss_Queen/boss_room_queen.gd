extends Node2D

@onready var queen        : Node  = $AntQueen
@onready var south_door   : Door  = $DoorS/DoorS
@onready var east_door    : Door  = $DoorE/DoorE
@onready var player : Player = $Player
@onready var _tree        : SceneTree = get_tree()

@export var ant_scene       : PackedScene
@export var fire_ant_scene  : PackedScene
@export var next_scene      : PackedScene        # ← drag the scene here!

# ────────────────────────────────────────────────────────────────
func _ready() -> void:
	# 1) close the exits immediately
	var stats = GameState.player_stats
	player.set_health(stats["current_health"])
	player.set_speed(stats["speed"])
	player.set_coins(stats["coins"])
	player.set_gun_attack(stats["gun_attack"])
	player.set_gun_speed(stats["gun_speed"])
	player.set_sword_attack(stats["sword_attack"])
	south_door.slam()
	east_door.slam()

	# 2) spawn helpers
	queen.spawn_soldiers.connect(spawn_soldiers)

	# 3) wait for the Queen to die
	if queen.has_signal("defeated"):
		queen.connect("defeated", _on_queen_defeated)

	# 4) when the EAST door is walked through, hop to the next scene
	east_door.door_entered.connect(_on_east_door_entered)

# ────────────────────────────────────────────────────────────────
# Queen beaten  →  open the east door
func _on_queen_defeated() -> void:
	await east_door.open()               # play anim & disable collider
	print("Boss beaten – East door reopened!")

# Player actually steps through the open door
func _on_east_door_entered(_pos: Vector2i, _dir: String, body: Node) -> void:
	if body.name != "Player" or east_door.sprite.animation != "open":
		return                            # ignore NPCs, bullets, etc.
	if next_scene:
		_tree.change_scene_to_packed(next_scene)

# ────────────────────────────────────────────────────────────────
func spawn_soldiers(kind: String) -> void:
	if (get_tree().get_nodes_in_group("enemy").size() >= 8*3): # Count attackboxes and hitboxes
		return

	var markers := $"Land Markers".get_children()
	for m in markers:
		var soldier : Node
		match kind:
			"ants":
				soldier = ant_scene.instantiate()
			"fire_ants":
				soldier = fire_ant_scene.instantiate()
			_:
				continue
		_tree.root.add_child(soldier)
		soldier.global_position = m.global_position
