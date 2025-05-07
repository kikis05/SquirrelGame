# BossDoor.gd  – attach to **DoorN (Area2D)** inside the BossDoor scene
extends Door
class_name BossDoor

#──────────────────────── editor – knobs ───────────────────────
@export var next_scene      : PackedScene               # boss‑arena scene
@export var interact_action : String       = "interact" # key mapped to **E**
@export var dialogue_box    : PackedScene = preload("res://NPCs/Dialog.tscn")

#──────────────────────── cached nodes ─────────────────────────
@onready var _sensor  : Area2D         = $DetectPlayer
@onready var _prompt  : RichTextLabel  = $"../Prompt"      # sibling
@onready var _dlg_sp  : Marker2D       = $"../DialogSpawn" # sibling
@onready var _tree    : SceneTree      = get_tree()

#──────────────────────── state flags ─────────────────────────
var _player_in_sensor : bool = false   # player stands near door
var _opened           : bool = false   # open animation already played
var _dialog_open      : bool = false   # dialogue box currently visible
var _confirmed        : bool = false   # player finished reading dialogue


#──────────────────────── built‑in ────────────────────────────
func _ready() -> void:
	# initialise the “regular” door first
	super()
	_prompt.visible = false

	# start *closed* and hide prompt
	slam()                # plays 'slam' & enables wall collider

	# signals
	_sensor.body_entered.connect(_on_sensor_enter)
	_sensor.body_exited .connect(_on_sensor_exit)
	door_entered           .connect(_on_door_entered)

	set_process_unhandled_input(true)


#──────────────────────── proximity sensor ─────────────────────
func _on_sensor_enter(body : Node) -> void:
	if _opened or body.name != "Player": return
	_player_in_sensor = true
	_prompt.visible   = true
	sprite.play("outline")


func _on_sensor_exit(body : Node) -> void:
	if _opened or body.name != "Player": return
	_player_in_sensor = false
	_prompt.visible   = false
	sprite.play("closed")
	await sprite.animation_finished
	sprite.frame = sprite.sprite_frames.get_frame_count("slam") - 1


#──────────────────────── input handling ──────────────────────
func _unhandled_input(event : InputEvent) -> void:
	if not _player_in_sensor or _opened or _dialog_open == true:
		return

	if event.is_action_pressed(interact_action):
		if not _confirmed:
			_show_dialogue()
		else:
			await _open_sequence()


#──────────────────────── dialogue box ────────────────────────
func _show_dialogue() -> void:
	_dialog_open = true
	_prompt.visible = false
	var dlg : Control = dialogue_box.instantiate()
	dlg.position = _dlg_sp.global_position        # spawn at marker
	_tree.current_scene.add_child(dlg)

	dlg.start([
		"Beyond this door lies the boss",
		"Once you go through, there is no coming back",
		"Press E again to enter…",
	])

	dlg.talk_finished.connect(func() -> void:
		_dialog_open = false
		_confirmed   = true
		_prompt.visible = true           # show “Press E” again
		sprite.play("outline")
	)


#──────────────────────── open door once ──────────────────────
func _open_sequence() -> void:
	_opened        = true
	_prompt.visible = false
	await open()                 # inherited async helper unlocks collider


#──────────────────────── walk‑through  →  boss scene ─────────
func _on_door_entered(_rp : Vector2i, _dir : String, body : Node) -> void:
	if not _opened or body.name != "Player": return
	if not next_scene:                       return

	# keep reference to player before changing scene
	var player : Node = body
	# fade‑out (optional – remove if you use a global TransitionScreen)
	# after change_scene_to_packed()
	_tree.change_scene_to_packed(next_scene)

	# ── make sure the new scene is fully instanced ─────────────────
	await _tree.process_frame                     # 1st frame → may still be null
	while _tree.current_scene == null:            # safety loop (1–2 frames max)
		await _tree.process_frame
	var new_root : Node = _tree.current_scene
	# ───────────────────────────────────────────────────────────────

	# now it's safe to fetch DoorS / SpawnPoint
	var spawn : Vector2 = Vector2.ZERO
	var door_s : Node   = new_root.get_node_or_null("DoorS")
	if door_s and door_s.has_node("SpawnPoint"):
		spawn = door_s.get_node("SpawnPoint").global_position
	elif new_root.has_node("SpawnPoint"):
		spawn = new_root.get_node("SpawnPoint").global_position

	new_root.add_child(player)
	player.global_position = spawn
