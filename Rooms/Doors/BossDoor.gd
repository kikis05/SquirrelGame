extends Door
class_name BossDoor

@export var next_scene    : PackedScene = preload("res://Rooms/Boss_Queen/boss_room_queen.tscn")
@export var interact_action : String = "interact"
@export var dialogue_box  : PackedScene = preload("res://NPCs/Dialog.tscn")
@export var ui_layer      : CanvasLayer      # drag your UI CanvasLayer here

@onready var _sensor : Area2D        = $DetectPlayer
@onready var _prompt : RichTextLabel = $"../Prompt"
@onready var _dlg_sp : Marker2D      = $"../DialogSpawn"
@onready var _tree   : SceneTree     = get_tree()

var _player_in_sensor := false
var _dialog_open      := false
var _confirmed        := false     # player pressed E once, read the warning
var _opening          := false     # door animation now playing

# ────────────────────────────────────────────────────────────────
func _ready() -> void:
	slam()                       # play “slam” once and freeze on the last frame
	sprite.frame = sprite.sprite_frames.get_frame_count("slam") - 1
	_prompt.visible = false

	_sensor.body_entered.connect(_on_sensor_enter)
	_sensor.body_exited .connect(_on_sensor_exit)

	set_process_unhandled_input(true)

# ────────────────────────────────────────────────────────────────
func _on_sensor_enter(body : Node) -> void:
	if body.name != "Player" or _opening:
		return
	_player_in_sensor = true
	_prompt.visible   = true       # sprite stays on “slam” frame – no animation

func _on_sensor_exit(body : Node) -> void:
	if body.name != "Player" or _opening:
		return
	_player_in_sensor = false
	_prompt.visible   = false

# ────────────────────────────────────────────────────────────────
func _unhandled_input(event : InputEvent) -> void:
	if !_player_in_sensor or _opening or _dialog_open:
		return

	if event.is_action_pressed(interact_action):
		if !_confirmed:
			_show_dialogue()
		else:
			await _open_sequence()

# ────────────────────────────────────────────────────────────────
func _show_dialogue() -> void:
	_dialog_open    = true
	_prompt.visible = false

	var dlg : Control = dialogue_box.instantiate()
	dlg.global_position = _dlg_sp.global_position   # world‑space pos
	ui_layer.add_child(dlg)                         # on top of everything

	dlg.start([
		"Beyond this door lies the boss.",
		"Once you go through, there is no coming back.",
		"Press E again to enter…",
	])

	dlg.talk_finished.connect(func() -> void:
		_dialog_open    = false
		_confirmed      = true
		_prompt.visible = true
	)

# ────────────────────────────────────────────────────────────────
func _open_sequence() -> void:
	_opening        = true
	_prompt.visible = false
	await open()                       # play “open” animation (from Door.gd)

	var player := get_tree().get_first_node_in_group("player")
	if player:
		_save_stats(player)
		_go_to_boss(player)

# ────────────────────────────────────────────────────────────────
func _save_stats(p : Node) -> void:
	GameState.player_stats.max_health     = p.max_health
	GameState.player_stats.current_health = p.current_health
	GameState.player_stats.coins          = p.coins
	GameState.player_stats.gun_attack     = p.get_gun_attack()
	GameState.player_stats.gun_speed      = p.get_gun_speed()
	GameState.player_stats.sword_attack   = p.get_sword_attack()
	GameState.player_stats.speed          = p.speed

# ────────────────────────────────────────────────────────────────
func _go_to_boss(player : Node) -> void:
	if not next_scene:
		push_error("BossDoor: next_scene not set!")
		return

	_tree.change_scene_to_packed(next_scene)

	# wait until the new scene is ready
	await _tree.process_frame
	while _tree.current_scene == null:
		await _tree.process_frame

	_tree.current_scene.add_child(player)
	player.global_position = $SpawnPoint.global_position
