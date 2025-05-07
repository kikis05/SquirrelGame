extends Node
class_name DungeonGenerator2

signal player_spawned(player : Node)
signal room_loaded(pos : Vector2i)  

@export var player_scene : PackedScene = preload("res://Player/player.tscn")
@export var dungeon_music : AudioStream        # drag your default BG track here
@export var shop_music    : AudioStream        # drag the “shop” jingle here
@onready var _music : AudioStreamPlayer2D = $"Music"
var _tint_color : Color                        # stored for all rooms
var _music_state : String = "dungeon"   # "dungeon"  |  "shop"


const GRID_WIDTH      = 5
const GRID_HEIGHT     = 5
const MIN_NONEMPTY    = 13  # Increased to account for special rooms
const MAX_ATTEMPTS    = 200 # Increased to handle additional constraints
const TILE_SIZE       = Vector2(160, 64)
var cleared_rooms := {}
var visited_rooms : Dictionary = {}  
var shop_room_pos : Vector2i = Vector2i(-1, -1)
var chest_rooms_pos : Array[Vector2i] = []
var boss_room_pos : Vector2i = Vector2i(-1, -1)

const CUSTOM_ROOMS := {
	"S":        ["SquareChestS", "SquareDoubleUpS"],
	"N": 		["SquareDoubleUpCircleN"],
	"NS":       ["NestLongNS", "SquareFishNS", "NestCircleNS", "SquareBottleneckNS"],
	"EW":       ["HolesEW", "MoundsEW", "TightSqueezeEW"],
	"NE":       ["SquareCornerNE"],
	"NW":       ["SquareCornerNW"],
	"SE":       ["SquareCornerSE"],
	"SW":       ["SquareCornerSW"],
	"NESW":     ["SquareFourCornersNESW"],
}

const CHEST_ROOMS := {
	"NEW":      ["NestChestBridgeNEW"],
	"ESW":      ["NestChestBridgeESW"],
	"EW":       ["NestBridgeEW"],
	"SW":		["NestChestSW"],
	"N":		["MosquitoMoundChestN"]
}

const SHOP_ROOMS := {
	"E": ["ShopE"],
	"N": ["ShopN"],
	"S": ["ShopS"],
	"W": ["ShopW"]
}

const BOSS_ROOMS := {
	"E": 	["BossRoomE"],
	"ES": 	["BossRoomES"],
	"ESW": 	["BossRoomESW"],
	"EW": 	["BossRoomEW"],
	"S":	["BossRoomS"],
	"W":	["BossRoomW"],
	"WS":	["BossRoomWS"]
}

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
	TransitionScreen.fade_in()
	rng.randomize()
	var hue := randf()                      # 0‒1
	_tint_color = Color.from_hsv(hue, 1.0, 1.0)   # full‑sat/value tint
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
		shop_room_pos = Vector2i(-1, -1)
		chest_rooms_pos.clear()

		var centre : Vector2i = Vector2i(GRID_WIDTH / 2, GRID_HEIGHT / 2)
		var first_index : int = rng.randi_range(0, ROOM_TYPES.size() - 1)
		var first_room : String = ROOM_TYPES.keys()[first_index]
		grid[centre.y][centre.x] = [first_room]
		collapsed[centre.y][centre.x] = first_room
		print("Seeded centre", centre, "with", first_room)

		_propagate(centre)
		_collapse_all()

		var nonempty : int = 0
		for y in range(GRID_HEIGHT):
			for x in range(GRID_WIDTH):
				if collapsed[y][x] != null and collapsed[y][x] != "EmptyRoom":
					nonempty += 1
		print("→ Non‑empty rooms:", nonempty)
		var connected := _count_connected_rooms(centre)
		print("→ Reachable from centre:", connected)

		# Ensure all non-empty rooms are connected
		if nonempty >= MIN_NONEMPTY and connected == nonempty:
			# Place special rooms and check success
			if _place_special_rooms():
				print("✅ Grid accepted with special rooms")
				# Fill remaining cells with EmptyRoom
				for y in range(GRID_HEIGHT):
					for x in range(GRID_WIDTH):
						if collapsed[y][x] == null:
							collapsed[y][x] = "EmptyRoom"
				return true

	print("❌ Could not satisfy WFC constraints")
	return false

func _place_special_rooms() -> bool:
	var candidate_positions := []
	var center := Vector2i(GRID_WIDTH / 2, GRID_HEIGHT / 2)
	
	# Collect valid candidate positions (non-center, non-empty, with matching exit patterns)
	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			var pos = Vector2i(x, y)
			if pos == center || collapsed[y][x] == "EmptyRoom":
				continue
				
			var exits = ROOM_TYPES[collapsed[y][x]]
			var dir_key := "".join(exits)
			
			# Update condition to include BOSS_ROOMS
			if SHOP_ROOMS.has(dir_key) || CHEST_ROOMS.has(dir_key) || BOSS_ROOMS.has(dir_key):
				candidate_positions.append({
					"pos": pos,
					"exits": exits,
					"dir_key": dir_key
				})
	
	# Update minimum candidate check
	if candidate_positions.size() < 4:  # Changed from 3 to 4 to account for boss room
		print("❌ Not enough candidate positions for special rooms")
		return false
	
	# Shuffle while keeping room data
	candidate_positions.shuffle()
	
	# Place shop room first
	var shop_placed := false
	for i in range(candidate_positions.size()):
		var data = candidate_positions[i]
		if SHOP_ROOMS.has(data.dir_key):
			collapsed[data.pos.y][data.pos.x] = "SHOP_" + data.dir_key
			shop_room_pos = data.pos
			candidate_positions.remove_at(i)
			shop_placed = true
			print("🏪 Shop room placed at:", data.pos, " with exits:", data.dir_key)
			break
			
	if not shop_placed:
		print("❌ Failed to place shop room")
		return false
	
	# Place chest rooms (need 2)
	var chests_placed := 0
	var to_remove := []
	for data in candidate_positions:
		if chests_placed >= 2:
			break
		if CHEST_ROOMS.has(data.dir_key):
			collapsed[data.pos.y][data.pos.x] = "CHEST_" + data.dir_key
			chest_rooms_pos.append(data.pos)
			chests_placed += 1
			to_remove.append(data)
			print("💰 Chest room placed at:", data.pos, " with exits:", data.dir_key)
	
	# Remove placed chest rooms from candidates
	for data in to_remove:
		candidate_positions.erase(data)
	
	if chests_placed < 2:
		print("❌ Only placed", chests_placed, "chest rooms (needed 2)")
		return false
	
	var boss_placed := false
	# Filter remaining candidates for boss-compatible rooms
	var boss_candidates = candidate_positions.filter(func(data): return BOSS_ROOMS.has(data.dir_key))
	if boss_candidates.size() > 0:
		var boss_data = boss_candidates[0]
		collapsed[boss_data.pos.y][boss_data.pos.x] = "BOSS_" + boss_data.dir_key
		boss_room_pos = boss_data.pos
		print("👑 Boss room placed at:", boss_data.pos, " with exits:", boss_data.dir_key)
		boss_placed = true
	
	if not boss_placed:
		print("❌ Failed to place boss room")
		return false
	
	# Print final room layout
	print("\n=== FINAL ROOM LAYOUT ===")
	_print_grid_layout()
	
	return true

func _print_grid_layout() -> void:
	var grid_display := ""
	for y in range(GRID_HEIGHT):
		var row := ""
		for x in range(GRID_WIDTH):
			var pos := Vector2i(x, y)
			var room = collapsed[y][x]
			if pos == shop_room_pos:
				row += "[$]"
			elif pos == boss_room_pos:
				row += "[B]"
			elif chest_rooms_pos.has(pos):
				row += "[C]"
			elif room == "EmptyRoom":
				row += "[ ]"
			else:
				row += "[X]"
			row += " "  # Add spacing between cells
		grid_display += row + "\n"
	
	print("Grid Key:")
	print("$ = Shop Room")
	print("B = Boss Room")
	print("C = Chest Room")
	print("X = Regular Room")
	print(" = Empty Room\n")
	print(grid_display)


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
	var room_name : String = collapsed[pos.y][pos.x]
		
	if pos.x < 0 or pos.x >= GRID_WIDTH or pos.y < 0 or pos.y >= GRID_HEIGHT:
		print("⚠ Out of bounds – aborting")
		return
		
	if room_name == "EmptyRoom":
		print("⚠ Target cell is EmptyRoom – aborting")
		return

	if current_room_instance:
		var tree = get_tree()
		if tree:
			tree.call_group("room_deletables", "queue_free")
		current_room_instance.queue_free()

	var directions := []
	var scene_path := ""
	var room_type := "standard"
	
	# Check for shop room first
	if room_name.begins_with("SHOP_"):
		room_type = "shop"
		var dir_key = room_name.replace("SHOP_", "")
		directions = _get_directions_from_key(dir_key)
		if SHOP_ROOMS.has(dir_key):
			scene_path = "res://Rooms/ShopRooms/%s.tscn" % SHOP_ROOMS[dir_key][0]
	
	# Then check for chest room
	elif room_name.begins_with("CHEST_"):
		room_type = "chest" 
		var dir_key = room_name.replace("CHEST_", "")
		directions = _get_directions_from_key(dir_key)
		if CHEST_ROOMS.has(dir_key):
			var options = CHEST_ROOMS[dir_key]
			var pick = options[rng.randi_range(0, options.size() - 1)]
			scene_path = "res://Rooms/Rooms_Anna/%s.tscn" % pick
	
	elif room_name.begins_with("BOSS_"):
		room_type = "boss"
		var dir_key = room_name.replace("BOSS_", "")
		directions = _get_directions_from_key(dir_key)
		if BOSS_ROOMS.has(dir_key):
			scene_path = "res://Rooms/Boss_Queen2/%s.tscn" % BOSS_ROOMS[dir_key][0]
	
	_update_music(room_type)
	# Then custom rooms
	if scene_path.is_empty():
		for exits in CUSTOM_ROOMS:
			if room_name in CUSTOM_ROOMS[exits]:
				directions = _get_directions_from_key(exits)
				var pick = CUSTOM_ROOMS[exits][rng.randi_range(0, CUSTOM_ROOMS[exits].size() - 1)]
				# Special cases for Anna2 folder
				if pick in ["SquareDoubleUpCircleN", "HolesEW", "MoundsEW", "TightSqueezeEW"]:
					scene_path = "res://Rooms/Rooms_Anna2/%s.tscn" % pick
				else:
					scene_path = "res://Rooms/Rooms_Anna/%s.tscn" % pick
				break
	
	# Fallback to standard rooms
	if scene_path.is_empty() and ROOM_TYPES.has(room_name):
		directions = ROOM_TYPES[room_name].duplicate()
		scene_path = "res://Rooms/StandardRoomScenes/%s.tscn" % room_name
	
	# Error handling
	if scene_path.is_empty():
		push_error("Unknown room type: " + room_name)
		return


	print("\u2022 Instancing room:", scene_path)
	current_room_instance = load(scene_path).instantiate()
	current_room_instance.name = "RoomInstance"
	current_room_instance.position = Vector2(pos.x, pos.y) * TILE_SIZE
	add_child(current_room_instance)
	(current_room_instance as CanvasItem).modulate = _tint_color

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

	if is_cleared:
		print("✅ Room was previously cleared:", pos)
		for door in get_tree().get_nodes_in_group("door"):
			if door.is_inside_tree() and current_room_instance.is_ancestor_of(door):
				door.open()
			for e in get_tree().get_nodes_in_group("enemy"):
				if e.is_inside_tree() and current_room_instance.is_ancestor_of(e):
					print("💀 Removing residual enemy from cleared room:", e.name)
					e.queue_free()
			for c in get_tree().get_nodes_in_group("chest"):
				if c.is_inside_tree() and current_room_instance.is_ancestor_of(c):
					print("Re-opening chest")
					c.set_chest(null)
	else:
		print("⚠ Room has enemies, slamming doors:", pos)
		for door in get_tree().get_nodes_in_group("door"):
			if door.is_inside_tree() and current_room_instance.is_ancestor_of(door):
				door.slam()
		await get_tree().process_frame
		_check_for_enemies(pos)

	# Player spawn logic
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

	if player == null:
		player = player_scene.instantiate()
		player.name = "Player"
		var stats = GameState.player_stats
		player.set_health(stats["current_health"])
		player.set_speed(stats["speed"])
		player.set_coins(stats["coins"])
		player.set_gun_attack(stats["gun_attack"])
		player.set_gun_speed(stats["gun_speed"])
		player.set_sword_attack(stats["sword_attack"])
		add_child(player)
		emit_signal("player_spawned", player)

	move_child(player, get_child_count() - 1)
	player.global_position = spawn
	print("• Player positioned at", spawn)

	current_room_pos = pos
	print("=== Room ready ===\n")
	visited_rooms[pos] = true

	await get_tree().process_frame
	emit_signal("room_loaded", pos)

func _get_directions_from_key(key: String) -> Array:
	var dirs := []
	for c in key:
		dirs.append(c)
	return dirs

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
	await get_tree().create_timer(0.5).timeout
	for e in get_tree().get_nodes_in_group("enemy"):
		if e is BaseEnemy and e.is_inside_tree() and current_room_instance.is_ancestor_of(e):
			print("🚫 Enemy still alive:", e.name)
			remaining_enemies += 1
	print("🔍 Total remaining enemies:", remaining_enemies)
	if remaining_enemies == 0:
		_clear_room(room_pos)

func _clear_room(room_pos: Vector2i):
	print("✅✅✅ All enemies gone — unlocking doors in room:", room_pos)
	for c in get_tree().get_nodes_in_group("chest"):
		if c.is_inside_tree() and current_room_instance.is_ancestor_of(c):
			print("Opening Chest")
			c.room_completed()
	cleared_rooms[room_pos] = true
	for door in get_tree().get_nodes_in_group("door"):
		if door.is_inside_tree() and current_room_instance.is_ancestor_of(door):
			print("→ Opening door:", door.name)
			door.open()

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
			continue
		
		var cur_exits : Array
		if cur_room.begins_with("SHOP_"):
			cur_exits = _get_directions_from_key(cur_room.replace("SHOP_", ""))
		elif cur_room.begins_with("CHEST_"):
			cur_exits = _get_directions_from_key(cur_room.replace("CHEST_", ""))
		elif cur_room.begins_with("BOSS_"):  # New condition
			cur_exits = _get_directions_from_key(cur_room.replace("BOSS_", ""))
		else:
			cur_exits = ROOM_TYPES[cur_room]

		for dir in DIRS:
			if dir not in cur_exits:
				continue
			var nxt : Vector2i = cur + DIR_OFFSET[dir]
			if nxt.x < 0 or nxt.x >= GRID_WIDTH or nxt.y < 0 or nxt.y >= GRID_HEIGHT:
				continue
			var nxt_room : String = collapsed[nxt.y][nxt.x]
			if nxt_room == "EmptyRoom":
				continue
			
			var nxt_exits : Array
			if nxt_room.begins_with("SHOP_"):
				nxt_exits = _get_directions_from_key(nxt_room.replace("SHOP_", ""))
			elif nxt_room.begins_with("CHEST_"):
				nxt_exits = _get_directions_from_key(nxt_room.replace("CHEST_", ""))
			else:
				nxt_exits = ROOM_TYPES[nxt_room]
			
			if OPPOSITE[dir] in nxt_exits:
				stack.append(nxt)

	return visited.size()

func _update_music(room_type : String) -> void:
	# room_type is "shop"  or anything else ("dungeon"/"boss"/"chest"/…)
	if room_type == "shop" and _music_state != "shop":
		_music.stream = shop_music
		_music.play()
		_music_state  = "shop"

	elif room_type != "shop" and _music_state != "dungeon":
		_music.stream = dungeon_music
		_music.play()
		_music_state  = "dungeon"
