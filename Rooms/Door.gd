extends Area2D
class_name Door                       # optional but still handy for the editor

# ────────── EDITOR-EXPOSED FIELDS ──────────
@export var direction : String = ""   # "N", "E", "S", "W"  (auto-filled if empty)

# ────────── CACHED NODES ──────────
@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var blocker_shape := $StaticBody2D/CollisionShape2D  # not the StaticBody2D itself

# ────────── STATE FILLED BY DUNGEON GENERATOR ──────────
var room_pos : Vector2i = Vector2i.ZERO   # (grid-x, grid-y) of the room this door belongs to
var dungeon  : Node      = null           # back-reference to the generator

# ────────── SIGNALS ──────────
signal door_entered(room_pos : Vector2i, direction : String, body : Node)

# ──────────────────────────────────────────────────────────────
func _ready() -> void:
	# 1) Ensure the node is tagged so the generator can find it quickly
	#if !is_in_group("door"):
		#add_to_group("door")          # no persistence needed

	# 2) Auto-derive the direction from the node name ("DoorN", "DoorE", …)
	if direction.is_empty() and name.begins_with("Door"):
		direction = name.substr(4, 1) # takes the 5th char

	print("[Door READY]  name:", name, " dir:", direction)

	# 3) Wire the Area2D signal to our local handler
	connect("body_entered", _on_body_entered)
	
	# 4) Make sure proper frame is showing
	sprite.stop()
	sprite.animation = "open"
	sprite.frame = sprite.sprite_frames.get_frame_count("open") - 1  # freeze at end

# ──────────────────────────────────────────────────────────────
func _on_body_entered(body : Node) -> void:
	if body.name == "Player":
		print("[Door ENTER] door:", name, " body:", body.name)
		emit_signal("door_entered", room_pos, direction, body)

# ────────── PUBLIC HELPERS (called by DungeonGenerator) ──────────
func slam() -> void:
	if sprite:
		sprite.play("slam")
		await sprite.animation_finished
		sprite.frame = sprite.sprite_frames.get_frame_count("slam") - 1
	if blocker_shape:
		blocker_shape.set_deferred("disabled", false)  # enable wall

func open() -> void:
	if sprite:
		if sprite.animation != "open":
			print("[Door OPEN] playing open on", name)
			sprite.play("open")
			await sprite.animation_finished
			sprite.frame = sprite.sprite_frames.get_frame_count("open") - 1  # freeze at end
	if blocker_shape:
		blocker_shape.set_deferred("disabled", true)
