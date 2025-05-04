extends Node

signal player_spawned(player : Node)

@export var player_scene : PackedScene = preload("res://Player/player.tscn")

# ────────── constants ───────────────────────────────────────────
const TILE_SIZE : Vector2 = Vector2(160, 64)   # world‑space units
const DIR_OFF  : Dictionary = {                # grid displacements
	"N": Vector2i(0,  1),   # move down
	"S": Vector2i(0, -1),   # move up
	"E": Vector2i(1,  0),
	"W": Vector2i(-1, 0)
}

const ROOMS : Dictionary = {                   # grid‑coord → scene
	Vector2i(0, 0): preload("res://Rooms/Tutorial/RoomIntro.tscn"),
	Vector2i(0, 1): preload("res://Rooms/Tutorial/RoomSap.tscn"),
	Vector2i(0, 2): preload("res://Rooms/Tutorial/RoomSword.tscn"),
	Vector2i(0, 3): preload("res://Rooms/Tutorial/RoomHole.tscn")
}

# ────────── runtime vars ────────────────────────────────────────
var _cur_room : Node     = null
var _cur_pos  : Vector2i = Vector2i.ZERO
var _player   : Node     = null

# ────────────────────────────────────────────────────────────────
func _ready() -> void:
	_switch_to_room(Vector2i(0, 0), "")          # start in intro room

# ─────────────── room switching ────────────────────────────────
func _switch_to_room(pos : Vector2i, entered_from_dir : String) -> void:
	if not ROOMS.has(pos):
		push_error("TutorialManager: no room at %s" % pos)
		return

	if _cur_room:
		_cur_room.queue_free()

	_cur_pos  = pos
	_cur_room = (ROOMS[pos] as PackedScene).instantiate()
	_cur_room.position = Vector2(pos) * TILE_SIZE
	add_child(_cur_room)

	_wire_doors_in(_cur_room, pos)
	_spawn_or_move_player(entered_from_dir)
	_inject_player_into_enemies(_cur_room)

# ----------------------------------------------------------------
func _wire_doors_in(room: Node, room_pos: Vector2i) -> void:
	# tag lives on the Area2D – just forward every “door_entered” to us
	for door in room.get_tree().get_nodes_in_group("door"):
		door.room_pos = room_pos
		door.dungeon  = self            # Door.gd expects this
		if not door.door_entered.is_connected(_on_door_entered):
			door.connect("door_entered", _on_door_entered)

func _on_door_entered(room_pos : Vector2i, dir : String, body : Node) -> void:
	if body.name != "Player":
		return
	_switch_to_room(room_pos + DIR_OFF[dir], dir)

# ─────────────── player handling ───────────────────────────────
func _spawn_or_move_player(from_dir : String) -> void:
	if _player == null:
		_player = player_scene.instantiate()
		_player.name = "Player"
		add_child(_player)
		emit_signal("player_spawned", _player)

	# default: Marker2D called “SpawnPoint” in every room
	var spawn : Vector2 = _cur_room.get_node("SpawnPoint").global_position

	# if we came through a door, try that door’s inner SpawnPoint instead
	if from_dir != "":
		var opp = { "N":"S", "S":"N", "E":"W", "W":"E" }[from_dir]
		var door_name = "Door" + opp                     # wrapper name
		var door_wrapper := _cur_room.get_node_or_null(door_name)
		if door_wrapper and door_wrapper.has_node("SpawnPoint"):
			spawn = door_wrapper.get_node("SpawnPoint").global_position

	_player.global_position = spawn

# ─────────────── enemy convenience ─────────────────────────────
func _inject_player_into_enemies(room : Node) -> void:
	for e in room.get_tree().get_nodes_in_group("enemy"):
		e.player = _player
