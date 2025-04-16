extends Node

var MIN_NONEMPTY_ROOMS := 10
var MAX_GRID_SIZE := 20

var GRID_WIDTH := 4
var GRID_HEIGHT := 4

const ROOM_TYPES := [
	"EmptyRoom",
	"StandardRoomN", "StandardRoomE", "StandardRoomS", "StandardRoomW",
	"StandardRoomNE", "StandardRoomNS", "StandardRoomNW",
	"StandardRoomES", "StandardRoomEW", "StandardRoomSW",
	"StandardRoomNES", "StandardRoomNEW", "StandardRoomNSW",
	"StandardRoomESW", "StandardRoomNESW"
]

var DOOR_CONFIGS := {
	"EmptyRoom":       [],
	"StandardRoomN":   ["N"],
	"StandardRoomE":   ["E"],
	"StandardRoomS":   ["S"],
	"StandardRoomW":   ["W"],
	"StandardRoomNE":  ["N", "E"],
	"StandardRoomNS":  ["N", "S"],
	"StandardRoomNW":  ["N", "W"],
	"StandardRoomES":  ["E", "S"],
	"StandardRoomEW":  ["E", "W"],
	"StandardRoomSW":  ["S", "W"],
	"StandardRoomNES": ["N", "E", "S"],
	"StandardRoomNEW": ["N", "E", "W"],
	"StandardRoomNSW": ["N", "S", "W"],
	"StandardRoomESW": ["E", "S", "W"],
	"StandardRoomNESW":["N", "E", "S", "W"]
}

var cell_possibilities : Array = []
var dungeon_layout : Array = []

func _ready():
	randomize()
	generate_dungeon_with_min_rooms(MIN_NONEMPTY_ROOMS)
	instance_dungeon()

func get_valid_room_types(x: int, y: int) -> Array:
	var valid = []
	for rtype in ROOM_TYPES:
		var doors = DOOR_CONFIGS[rtype]
		if "N" in doors and y == 0: continue
		if "S" in doors and y == GRID_HEIGHT - 1: continue
		if "W" in doors and x == 0: continue
		if "E" in doors and x == GRID_WIDTH - 1: continue
		valid.append(rtype)
	return valid

func initialize():
	cell_possibilities.clear()
	dungeon_layout.clear()
	for y in range(GRID_HEIGHT):
		var row_poss = []
		var row_layout = []
		for x in range(GRID_WIDTH):
			row_poss.append(get_valid_room_types(x, y))
			row_layout.append(null)
		cell_possibilities.append(row_poss)
		dungeon_layout.append(row_layout)

func find_lowest_entropy_cell() -> Vector2:
	var min_entropy = 999999
	var best_cell = Vector2(-1, -1)
	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			var count = cell_possibilities[y][x].size()
			if count > 1 and count < min_entropy:
				min_entropy = count
				best_cell = Vector2(x, y)
	return best_cell

func propagate_constraints_deep(start_x: int, start_y: int):
	var queue: Array = [Vector2(start_x, start_y)]
	var direction_map = {
		"N": {"dx": 0, "dy": -1, "opposite": "S"},
		"E": {"dx": 1, "dy": 0,  "opposite": "W"},
		"S": {"dx": 0, "dy": 1,  "opposite": "N"},
		"W": {"dx": -1,"dy": 0,  "opposite": "E"},
	}

	while queue.size() > 0:
		var current = queue.pop_front()
		var cx = int(current.x)
		var cy = int(current.y)
		var current_type = dungeon_layout[cy][cx]
		if current_type == null:
			continue
		var current_doors = DOOR_CONFIGS[current_type]

		for dir in direction_map.keys():
			var dx = direction_map[dir].dx
			var dy = direction_map[dir].dy
			var opposite = direction_map[dir].opposite

			var nx = cx + dx
			var ny = cy + dy
			if nx < 0 or nx >= GRID_WIDTH or ny < 0 or ny >= GRID_HEIGHT:
				continue

			var neighbor_poss = cell_possibilities[ny][nx]
			var new_poss = []

			var current_has = current_doors.has(dir)

			for ntype in neighbor_poss:
				var ndoors = DOOR_CONFIGS[ntype]
				var neighbor_has = ndoors.has(opposite)

				if current_type == "EmptyRoom":
					if neighbor_has: continue
				elif ntype == "EmptyRoom":
					if current_has: continue
				elif current_has != neighbor_has:
					continue

				new_poss.append(ntype)

			if new_poss.size() < neighbor_poss.size():
				cell_possibilities[ny][nx] = new_poss
				if new_poss.size() == 1 and dungeon_layout[ny][nx] == null:
					dungeon_layout[ny][nx] = new_poss[0]
					queue.append(Vector2(nx, ny))
				elif new_poss.size() > 0:
					queue.append(Vector2(nx, ny))

func generate_dungeon_once() -> bool:
	initialize()
	while true:
		var cell = find_lowest_entropy_cell()
		if cell.x == -1:
			return true
		var poss = cell_possibilities[cell.y][cell.x]
		if poss.size() == 0:
			return false
		var chosen = poss[randi() % poss.size()]
		cell_possibilities[cell.y][cell.x] = [chosen]
		dungeon_layout[cell.y][cell.x] = chosen
		propagate_constraints_deep(cell.x, cell.y)
	return false

func generate_dungeon_with_min_rooms(min_rooms: int):
	for size in range(4, MAX_GRID_SIZE + 1):
		GRID_WIDTH = size
		GRID_HEIGHT = size
		for attempt in range(100):
			if generate_dungeon_once() and is_fully_connected():
				var count := 0
				for y in range(GRID_HEIGHT):
					for x in range(GRID_WIDTH):
						var t = dungeon_layout[y][x]
						if t != null and t != "EmptyRoom":
							count += 1
				if count >= min_rooms:
					print("✅ Dungeon with %d rooms generated in grid %dx%d" % [count, GRID_WIDTH, GRID_HEIGHT])
					return
	push_warning("❌ Failed to generate dungeon with %d rooms after max grid/attempts." % min_rooms)

func is_fully_connected() -> bool:
	var visited := []
	for y in range(GRID_HEIGHT):
		visited.append([])
		for x in range(GRID_WIDTH):
			visited[y].append(false)

	var directions := {
		"N": Vector2(0, -1),
		"S": Vector2(0, 1),
		"E": Vector2(1, 0),
		"W": Vector2(-1, 0)
	}
	var opposites := {
		"N": "S",
		"S": "N",
		"E": "W",
		"W": "E"
	}

	var start := Vector2(-1, -1)
	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			var t = dungeon_layout[y][x]
			if t != null and t != "EmptyRoom":
				start = Vector2(x, y)
				break
		if start.x != -1:
			break
	if start.x == -1:
		return false

	var queue := [start]
	visited[start.y][start.x] = true

	while queue.size() > 0:
		var pos = queue.pop_front()
		var room_type = dungeon_layout[pos.y][pos.x]
		var doors = DOOR_CONFIGS[room_type]

		for d in doors:
			var neighbor = pos + directions[d]
			if not (neighbor.x >= 0 and neighbor.x < GRID_WIDTH and neighbor.y >= 0 and neighbor.y < GRID_HEIGHT):
				continue
			var neighbor_type = dungeon_layout[neighbor.y][neighbor.x]
			if neighbor_type == null or neighbor_type == "EmptyRoom":
				continue
			var neighbor_doors = DOOR_CONFIGS[neighbor_type]
			if opposites[d] in neighbor_doors and not visited[neighbor.y][neighbor.x]:
				visited[neighbor.y][neighbor.x] = true
				queue.append(neighbor)

	var total_rooms := 0
	var connected_rooms := 0
	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			if dungeon_layout[y][x] != null and dungeon_layout[y][x] != "EmptyRoom":
				total_rooms += 1
				if visited[y][x]:
					connected_rooms += 1

	return total_rooms == connected_rooms

func instance_dungeon():
	var cell_size = Vector2(640, 360)
	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			var rtype = dungeon_layout[y][x]
			if rtype == null or rtype == "EmptyRoom":
				continue
			var path = "res://Rooms/StandardRoomScenes/" + rtype + ".tscn"
			if not ResourceLoader.exists(path):
				path = "res://Rooms/StandardRoomScenes/StandardRoomNESW.tscn"
			var scene = load(path)
			if scene:
				var inst = scene.instantiate()
				add_child(inst)
				inst.position = Vector2(x, y) * cell_size
