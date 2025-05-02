extends Node
class_name DungeonGenerator

signal player_spawned(player : Node)
signal room_loaded(pos : Vector2i)  

@export var player_scene : PackedScene = preload("res://Player/player.tscn")

const GRID_WIDTH      = 5
const GRID_HEIGHT     = 5
const MIN_NONEMPTY    = 10
const MAX_ATTEMPTS    = 100
const TILE_SIZE       = Vector2(160, 64)
var cleared_rooms := {}  # Dictionary<Vector2i, bool>
var visited_rooms : Dictionary = {}  

const ROOM_TYPES = {
	"EmptyRoom":        [],
	"StandardRoomN":    ["N"],
	"StandardRoomE":    ["E"],
	"StandardRoomS":    ["S"],
	"StandardRoomW":    ["W"],
	"StandardRoomNE":   ["N","E"],
	"StandardRoomNS":   ["N","S"],
	"StandardRoomNW":   ["N","W"],
	"StandardRoomES":   ["E","S"],
	"StandardRoomEW":   ["E","W"],
	"StandardRoomSW":   ["S","W"],
	"StandardRoomNES":  ["N","E","S"],
	"StandardRoomNEW":  ["N","E","W"],
	"StandardRoomNSW":  ["N","S","W"],
	"StandardRoomESW":  ["E","S","W"],
	"StandardRoomNESW": ["N","E","S","W"],
}

const DIRS = ["N","E","S","W"]
const OPPOSITE = {"N":"S", "E":"W", "S":"N", "W":"E"}
const DIR_OFFSET = {
	"N": Vector2i( 0,-1),
	"E": Vector2i( 1, 0),
	"S": Vector2i( 0, 1),
	"W": Vector2i(-1, 0)
}

var grid : Array = []
var collapsed : Array = []
var current_room_pos : Vector2i = Vector2i.ZERO
var current_room_instance : Node = null
var player : Node = null
var rng : RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	print("\n=== DungeonGenerator READY ===")
	if _generate_dungeon():
		current_room_pos = Vector2i(GRID_WIDTH / 2, GRID_HEIGHT / 2)
		print("▶ Initial room:", current_room_pos)
		_switch_to_room(current_room_pos, "")
	else:
		push_error("❌ Failed to build dungeon after %s attempts" % MAX_ATTEMPTS)

func _generate_dungeon() -> bool:
	print("\n=== Generating dungeon grid with WFC ===")
	for attempt in range(MAX_ATTEMPTS):
		print("--- Attempt", attempt, "of", MAX_ATTEMPTS, "---")
		_init_grid()

		var centre : Vector2i = Vector2i(GRID_WIDTH / 2, GRID_HEIGHT / 2)
		var first_index : int = rng.randi_range(0, ROOM_TYPES.size() - 1)
		var first_room : String = ROOM_TYPES.keys()[first_index]
		grid[centre.y][centre.x] = [first_room]
		collapsed[centre.y][centre.x] = first_room
		print("Seeded centre", centre, "with", first_room)

		_propagate(centre)
		_collapse_all()

		var nonempty : int = 0
		for row in collapsed:
			for cell in row:
				if cell != null and cell != "EmptyRoom":
					nonempty += 1
		print("→ Non‑empty rooms:", nonempty)
		var connected := _count_connected_rooms(centre)
		print("→ Reachable from centre:", connected)

		if nonempty >= MIN_NONEMPTY and connected >= MIN_NONEMPTY:
			print("✅ Grid accepted")
			for y in range(GRID_HEIGHT):
				for x in range(GRID_WIDTH):
					if collapsed[y][x] == null:
						collapsed[y][x] = "EmptyRoom"
			return true

	print("❌ Could not satisfy WFC constraints")
	return false

func _init_grid() -> void:
	grid.clear()
	collapsed.clear()
	for y in range(GRID_HEIGHT):
		var g_row : Array = []
		var c_row : Array = []
		for x in range(GRID_WIDTH):
			var valid_room_types : Array = []
			for room_name in ROOM_TYPES.keys():
				var exits = ROOM_TYPES[room_name]
				var is_valid = true
				for dir in exits:
					var nx = x + DIR_OFFSET[dir].x
					var ny = y + DIR_OFFSET[dir].y
					if nx < 0 or nx >= GRID_WIDTH or ny < 0 or ny >= GRID_HEIGHT:
						is_valid = false
						break
				if is_valid:
					valid_room_types.append(room_name)
			g_row.append(valid_room_types)
			c_row.append(null)
		grid.append(g_row)
		collapsed.append(c_row)
	print("• Grid initialised with bounded room options")

func _collapse_all() -> void:
	while true:
		var cell : Vector2i = _lowest_entropy_cell()
		if cell.x == -1:
			print("• All cells collapsed")
			return
		var options : Array = grid[cell.y][cell.x]
		var pick : String = options[rng.randi_range(0, options.size() - 1)]
		grid[cell.y][cell.x] = [pick]
		collapsed[cell.y][cell.x] = pick
		print("  Collapsed", cell, "→", pick)
		_propagate(cell)

func _lowest_entropy_cell() -> Vector2i:
	var best : Vector2i = Vector2i(-1, -1)
	var min_entropy : float = INF
	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			if collapsed[y][x] == null:
				var count : int = grid[y][x].size()
				if count > 1 and count < min_entropy:
					min_entropy = count
					best = Vector2i(x, y)
	return best

func _propagate(start : Vector2i) -> void:
	var queue : Array = [start]
	var visited : Dictionary = {}
	while queue.size() > 0:
		var current : Vector2i = queue.pop_front()
		if visited.has(current):
			continue
		visited[current] = true
		for dir in DIRS:
			var neighbour : Vector2i = current + DIR_OFFSET[dir]
			if neighbour.x < 0 or neighbour.x >= GRID_WIDTH or neighbour.y < 0 or neighbour.y >= GRID_HEIGHT:
				continue
			if collapsed[neighbour.y][neighbour.x] != null:
				continue

			var valid : Array = []
			for opt in grid[current.y][current.x]:
				for r in ROOM_TYPES.keys():
					var cond1 : bool = dir in ROOM_TYPES[opt] and OPPOSITE[dir] in ROOM_TYPES[r]
					var cond2 : bool = dir not in ROOM_TYPES[opt] and OPPOSITE[dir] not in ROOM_TYPES[r]
					if cond1 or cond2:
						valid.append(r)

			var new_list : Array = []
			for item in grid[neighbour.y][neighbour.x]:
				if valid.has(item):
					new_list.append(item)

			if new_list.size() < grid[neighbour.y][neighbour.x].size():
				grid[neighbour.y][neighbour.x] = new_list
				print("    Updated", neighbour, "options →", new_list)
				if new_list.size() == 1:
					collapsed[neighbour.y][neighbour.x] = new_list[0]
					queue.append(neighbour)

func _switch_to_room(pos : Vector2i, entered_from_dir : String) -> void:
	print("\n=== Switching to", pos, "from:", entered_from_dir, "===")

	if pos.x < 0 or pos.x >= GRID_WIDTH or pos.y < 0 or pos.y >= GRID_HEIGHT:
		print("⚠ Out of bounds – aborting")
		return

	var room_name : String = collapsed[pos.y][pos.x]
	if room_name == "EmptyRoom":
		print("⚠ Target cell is EmptyRoom – aborting")
		return

	if current_room_instance:
		get_tree().call_group("room_deletables", "queue_free")
		current_room_instance.queue_free()

	var scene_path : String = "res://Rooms/StandardRoomScenes/%s.tscn" % room_name
	print("• Instancing room:", scene_path)
	current_room_instance = load(scene_path).instantiate()
	current_room_instance.name = "RoomInstance"

	current_room_instance.position = Vector2(pos.x, pos.y) * TILE_SIZE
	add_child(current_room_instance)

	_wire_doors_recursive(current_room_instance, pos)

	var is_cleared = cleared_rooms.get(pos, false)

	# First room logic (remove enemies, mark cleared early)
	if pos == Vector2i(GRID_WIDTH / 2, GRID_HEIGHT / 2):
		print("🧹 Removing enemies from spawn room")
		for e in current_room_instance.get_tree().get_nodes_in_group("enemy"):
			if e.is_inside_tree() and current_room_instance.is_ancestor_of(e):
				e.queue_free()
		cleared_rooms[pos] = true
		is_cleared = true

	await get_tree().process_frame

	# 🔓 Open or 🔒 slam doors based on clearance
	if is_cleared:
		print("✅ Room was previously cleared:", pos)
		for door in get_tree().get_nodes_in_group("door"):
			if door.is_inside_tree() and current_room_instance.is_ancestor_of(door):
				door.open()
			for e in get_tree().get_nodes_in_group("enemy"):
				if e.is_inside_tree() and current_room_instance.is_ancestor_of(e):
					print("💀 Removing residual enemy from cleared room:", e.name)
					e.queue_free()
	else:
		print("⚠ Room has enemies, slamming doors:", pos)
		for door in get_tree().get_nodes_in_group("door"):
			if door.is_inside_tree() and current_room_instance.is_ancestor_of(door):
				door.slam()
		await get_tree().process_frame
		_check_for_enemies(pos)

	await get_tree().process_frame

	_wire_doors_recursive(current_room_instance, pos)

	if is_cleared:
		print("✅ Room was previously cleared:", pos)
		for door in get_tree().get_nodes_in_group("door"):
			if door.is_inside_tree() and current_room_instance.is_ancestor_of(door):
				door.open()
	else:
		print("⚠ Room has enemies, slamming doors:", pos)
		for door in get_tree().get_nodes_in_group("door"):
			if door.is_inside_tree() and current_room_instance.is_ancestor_of(door):
				door.slam()
		await get_tree().process_frame
		_check_for_enemies(pos)

	# ───────── Player Spawn Logic ─────────
	var spawn : Vector2

	if entered_from_dir == "":
		var room_spawn := current_room_instance.get_node_or_null("SpawnPoint")
		if room_spawn:
			spawn = room_spawn.global_position
			print("🟢 First room spawn:", spawn)
		else:
			spawn = Vector2(320, 180)
			print("⚠ First room fallback spawn used")
	else:
		var opposite_dir = OPPOSITE[entered_from_dir]
		var target_door_name = "Door" + opposite_dir
		var found := false
		for child in current_room_instance.get_children():
			if child.name == target_door_name and child.has_node("SpawnPoint"):
				var door_spawn_point := child.get_node("SpawnPoint")
				spawn = door_spawn_point.global_position
				print("▶ Door spawn from:", target_door_name, "→", spawn)
				found = true
				break
		if !found:
			spawn = Vector2(320, 180)
			print("⚠ Couldn't find door spawn, using fallback position")

	# ───────── Spawn or reuse Player ─────────
	if player == null:
		player = player_scene.instantiate()
		player.name = "Player"
		add_child(player)
		emit_signal("player_spawned", player)

	move_child(player, get_child_count() - 1)
	player.global_position = spawn
	print("• Player positioned at", spawn)

	current_room_pos = pos
	print("=== Room ready ===\n")
	visited_rooms[pos] = true                    # mark visited

	await get_tree().process_frame
	emit_signal("room_loaded", pos)

func _wire_doors_recursive(node : Node, room_pos : Vector2i) -> void:
	for child in node.get_children():
		if child is Door:
			child.room_pos = room_pos
			child.dungeon  = self
			child.connect("door_entered", _on_door_entered)
			print("  ↳ Wired Door:", child.name, "dir:", child.direction, "room:", room_pos)
		_wire_doors_recursive(child, room_pos)

func _on_door_entered(room_pos : Vector2i, dir : String, body : Node) -> void:
	if body.name != "Player":
		return
	print("\n>>> DOOR TRIGGER  room_pos:", room_pos, " dir:", dir, " <<<")
	var target : Vector2i = room_pos + DIR_OFFSET[dir]
	print("    Target room:", target)
	_switch_to_room(target, dir)

func start_game():
	if _generate_dungeon():
		current_room_pos = Vector2i(GRID_WIDTH / 2, GRID_HEIGHT / 2)
		_switch_to_room(current_room_pos, "")
	else:
		push_error("❌ Failed to build dungeon after %s attempts" % MAX_ATTEMPTS)

func _check_for_enemies(room_pos: Vector2i):
	var enemies := []
	for e in get_tree().get_nodes_in_group("enemy"):
		if e.is_inside_tree() and current_room_instance.is_ancestor_of(e):
			enemies.append(e)

	if enemies.is_empty():
		print("🧠 No enemies found — clearing room")
		_clear_room(room_pos)
	else:
		print("🧠 Enemies remaining:", enemies.size())
		for enemy in enemies:
			print("🕷 Tracking enemy:", enemy.name)
			if "enemy_defeated" in enemy:
				if not enemy.enemy_defeated.is_connected(func(): _check_if_room_cleared(room_pos)):
					enemy.enemy_defeated.connect(func(): _check_if_room_cleared(room_pos))
					print("✔ Connected enemy_defeated for", enemy.name)
				else:
					print("🔁 Already connected:", enemy.name)

func _check_if_room_cleared(room_pos: Vector2i):
	print("🧪 Checking if room is cleared:", room_pos)
	var remaining_enemies := 0
	for e in get_tree().get_nodes_in_group("enemy"):
		if e is BaseEnemy and e.is_inside_tree() and current_room_instance.is_ancestor_of(e):
			print("🚫 Enemy still alive:", e.name)
			remaining_enemies += 1
	print("🔍 Total remaining enemies:", remaining_enemies)
	if remaining_enemies == 1:
		_clear_room(room_pos)

func _clear_room(room_pos: Vector2i):
	print("✅✅✅ All enemies gone — unlocking doors in room:", room_pos)
	cleared_rooms[room_pos] = true
	for door in get_tree().get_nodes_in_group("door"):
		if door.is_inside_tree() and current_room_instance.is_ancestor_of(door):
			print("→ Opening door:", door.name)
			door.open()

# Returns how many non-empty rooms can be reached from `start`
# by walking only through door pairs that correctly face each other.
func _count_connected_rooms(start : Vector2i) -> int:
	var visited : Dictionary = {}
	var stack : Array       = [start]

	while stack:
		var cur : Vector2i = stack.pop_back()
		if visited.has(cur):
			continue
		visited[cur] = true

		var cur_room : String = collapsed[cur.y][cur.x]
		if cur_room == "EmptyRoom":
			continue                       # shouldn’t happen, but be safe
		var cur_exits : Array = ROOM_TYPES[cur_room]

		for dir in DIRS:
			if dir not in cur_exits:       # no door that way
				continue
			var nxt : Vector2i = cur + DIR_OFFSET[dir]
			if nxt.x < 0 or nxt.x >= GRID_WIDTH \
			or nxt.y < 0 or nxt.y >= GRID_HEIGHT:
				continue                   # off the grid
			var nxt_room : String = collapsed[nxt.y][nxt.x]
			if nxt_room == "EmptyRoom":
				continue
			# Only traverse if BOTH rooms’ doors face each other
			if OPPOSITE[dir] in ROOM_TYPES[nxt_room]:
				stack.append(nxt)

	return visited.size()
