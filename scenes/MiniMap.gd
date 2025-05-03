extends Control
class_name MiniMap

@export var dungeon : Node                    

# ───────── appearance ─────────────────────────────────────
const CELL        = 8                        # pixels per grid square
const INSET       = 1
const CONNECT_T   = 2  
const BORDER_W    = 1                          # border line width
const FRAME_CLR   = Color.WHITE
const BACK_CLR    = Color.BLACK
const ROOM_CLR    = Color(0.8, 0.8, 0.8)       # visited room
const PLAYER_CLR  = Color(1, 0.2, 0.2)         # current room

# ───────── state ──────────────────────────────────────────
var player_pos : Vector2i = Vector2i.ZERO

func _ready() -> void:
	# total map size (dungeon grid × cell size)
	size = Vector2(dungeon.GRID_WIDTH, dungeon.GRID_HEIGHT) * CELL

	# pin to top‑right, 32 px in from the edges
	set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT, 0, true)
	offset_right = -48
	offset_top   =  8
	offset_left  =  offset_right - size.x
	offset_bottom = offset_top + size.y

	dungeon.room_loaded.connect(_on_room_loaded)
	_on_room_loaded(Vector2i(dungeon.GRID_WIDTH / 2, dungeon.GRID_HEIGHT / 2))

func _on_room_loaded(pos : Vector2i) -> void:
	player_pos = pos
	queue_redraw()

func _draw() -> void:
	var cell_size  := Vector2(CELL, CELL)
	var grid_size  := Vector2(dungeon.GRID_WIDTH, dungeon.GRID_HEIGHT) * CELL + Vector2(1, 1)
	var inner_size := Vector2(CELL - 2*INSET, CELL - 2*INSET)

	# 1 · solid black for every cell
	for y in range(dungeon.GRID_HEIGHT):
		for x in range(dungeon.GRID_WIDTH):
			draw_rect(Rect2(Vector2(x, y) * CELL, cell_size), BACK_CLR)

	# 2 · visited rooms (grey inset squares)
	for key in dungeon.visited_rooms.keys():
		var pos := Vector2(key) * CELL + Vector2(INSET, INSET)
		draw_rect(Rect2(pos, inner_size), ROOM_CLR)

	# 3 · door connectors between visited neighbours  ────────────────
	for key in dungeon.visited_rooms.keys():
		var room_name : String   = dungeon.collapsed[key.y][key.x]
		var exits     : Array    = dungeon.ROOM_TYPES[room_name]

		for dir in exits:
			var neigh = key + dungeon.DIR_OFFSET[dir]
			if not dungeon.visited_rooms.has(neigh):
				continue                      # neighbour not visited ⇒ don’t draw

			var base_px := Vector2(key) * CELL
			match dir:
				"N":
					var y := base_px.y + INSET
					var x := base_px.x + CELL/2 - CONNECT_T/2
					draw_rect(Rect2(Vector2(x, y-CONNECT_T), Vector2(CONNECT_T, CONNECT_T)), ROOM_CLR)
				"E":
					var x := base_px.x + CELL - INSET
					var y := base_px.y + CELL/2 - CONNECT_T/2
					draw_rect(Rect2(Vector2(x, y), Vector2(CONNECT_T, CONNECT_T)), ROOM_CLR)
				"S":
					var y := base_px.y + CELL - INSET
					var x := base_px.x + CELL/2 - CONNECT_T/2
					draw_rect(Rect2(Vector2(x, y), Vector2(CONNECT_T, CONNECT_T)), ROOM_CLR)
				"W":
					var x := base_px.x + INSET
					var y := base_px.y + CELL/2 - CONNECT_T/2
					draw_rect(Rect2(Vector2(x-CONNECT_T, y), Vector2(CONNECT_T, CONNECT_T)), ROOM_CLR)

	# 4 · current player room (red inset square)
	var player_px := Vector2(player_pos) * CELL + Vector2(INSET, INSET)
	draw_rect(Rect2(player_px, inner_size), PLAYER_CLR)

	# 5 · outer white frame
	draw_rect(Rect2(Vector2.ZERO, grid_size), FRAME_CLR, false, BORDER_W)
