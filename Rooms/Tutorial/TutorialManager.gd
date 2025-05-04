# TutorialManager.gd ───────────────────────────────────────────────
extends Node
class_name TutorialManager

signal player_spawned(player : Node)

@export var player_scene : PackedScene = preload("res://Player/player.tscn")

const TILE_SIZE : Vector2 = Vector2(160, 64)            # world‑space units
const DIR_OFF   : Dictionary = {
	"N": Vector2i(0,  1),   # move *down* one row
	"S": Vector2i(0, -1),   # move *up*   one row
	"E": Vector2i(1,  0),
	"W": Vector2i(-1, 0)
}

const ROOMS : Dictionary = {
	Vector2i(0, 0): preload("res://Rooms/Tutorial/RoomIntro.tscn"),
	Vector2i(0, 1): preload("res://Rooms/Tutorial/RoomSap.tscn"),
	Vector2i(0, 2): preload("res://Rooms/Tutorial/RoomSword.tscn"),
	Vector2i(0, 3): preload("res://Rooms/Tutorial/RoomHole.tscn")
}

var _cur_room : Node     = null
var _cur_pos  : Vector2i = Vector2i.ZERO
var _player   : Node     = null

# ───────────────────────────────────────────────────────────────
func _ready() -> void:
	_switch_to_room(Vector2i(0, 0), "")     # start in the intro room

# ───────────────────── room switching ───────────────────────────
func _switch_to_room(pos : Vector2i, entered_from_dir : String) -> void:
	if not ROOMS.has(pos):
		push_error("TutorialManager: no room at %s" % pos)
		return

	get_tree().call_group("room_deletables", "queue_free")

	if _cur_room:
		_cur_room.queue_free()

	_cur_pos  = pos
	_cur_room = (ROOMS[pos] as PackedScene).instantiate()
	_cur_room.position = Vector2(pos) * TILE_SIZE   # cast Vector2i → Vector2
	add_child(_cur_room)

	_wire_doors_in(_cur_room, pos)
	_spawn_or_move_player(entered_from_dir)
	_inject_player_into_enemies(_cur_room)

# ----------------------------------------------------------------
func _wire_doors_in(room: Node, room_pos: Vector2i) -> void:
	for holder in room.get_tree().get_nodes_in_group("door"):
		var door : Door = _find_real_door(holder)
		if door:
			door.room_pos = room_pos
			door.dungeon  = self
			if not door.door_entered.is_connected(_on_door_entered):
				door.connect("door_entered", _on_door_entered)

func _on_door_entered(room_pos : Vector2i, dir : String, body : Node) -> void:
	if body.name != "Player": return
	_switch_to_room(room_pos + DIR_OFF[dir], dir)

# ───────────────────── player management ───────────────────────
func _spawn_or_move_player(from_dir : String) -> void:
	if _player == null:
		_player = player_scene.instantiate()
		_player.name = "Player"
		add_child(_player)
		emit_signal("player_spawned", _player)

	var spawn : Vector2 = _cur_room.get_node("SpawnPoint").global_position

	if from_dir != "":
		var opp = {"N":"S","S":"N","E":"W","W":"E"}[from_dir]
		var door_spawn := _find_door_spawn(opp)
		if door_spawn: spawn = door_spawn

	_player.global_position = spawn

func _find_door_spawn(dir : String) -> Vector2:
	for holder in _cur_room.get_tree().get_nodes_in_group("door"):
		var door : Door = _find_real_door(holder)
		if door and door.direction == dir and door.has_node("SpawnPoint"):
			return door.get_node("SpawnPoint").global_position
	return Vector2.ZERO      # caller keeps previous value if (0,0)

# ───────────────────── helper: unwrap wrapper nodes ─────────────
func _find_real_door(holder : Node) -> Door:
	if holder is Door:
		return holder
	for child in holder.get_children():
		if child is Door:
			return child
	return null

# ───────────────────── enemy convenience ───────────────────────
func _inject_player_into_enemies(room : Node) -> void:
	for e in room.get_tree().get_nodes_in_group("enemy"):
		e.player = _player
