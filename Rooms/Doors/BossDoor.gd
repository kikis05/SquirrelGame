extends Door
class_name BossDoor

@export var next_scene: PackedScene = preload("res://Rooms/Boss_Queen/boss_room_queen.tscn")
@export var interact_action: String = "interact"
@export var dialogue_box: PackedScene = preload("res://NPCs/Dialog.tscn")
@export var ui_layer : CanvasLayer

@onready var _sensor: Area2D = $DetectPlayer
@onready var _prompt: RichTextLabel = $"../Prompt"
@onready var _dlg_sp: Marker2D = $"../DialogSpawn"
@onready var _tree: SceneTree = get_tree()

var _player_in_sensor: bool = false
var _opened: bool = false
var _dialog_open: bool = false
var _confirmed: bool = false

func _ready() -> void:
	super()
	_prompt.visible = false
	slam()
	
	# Connect signals
	_sensor.body_entered.connect(_on_sensor_enter)
	_sensor.body_exited.connect(_on_sensor_exit)
	door_entered.connect(_on_door_entered)
	
	# Ensure we process input
	set_process_unhandled_input(true)

func _on_sensor_enter(body: Node) -> void:
	if _opened or body.name != "Player": return
	_player_in_sensor = true
	_prompt.visible = true
	sprite.play("outline")

func _on_sensor_exit(body: Node) -> void:
	if _opened or body.name != "Player": return
	_player_in_sensor = false
	_prompt.visible = false
	sprite.play("closed")
	await sprite.animation_finished
	sprite.frame = sprite.sprite_frames.get_frame_count("slam") - 1

func _unhandled_input(event: InputEvent) -> void:
	if not _player_in_sensor or _opened or _dialog_open:
		return

	if event.is_action_pressed(interact_action):
		if not _confirmed:
			_show_dialogue()
		else:
			await _open_sequence()

func _show_dialogue() -> void:
	_dialog_open = true
	_prompt.visible = false
	var dlg: Control = dialogue_box.instantiate()
	ui_layer.add_child(dlg)
	dlg.position = _dlg_sp.global_position
	_tree.current_scene.add_child(dlg)

	dlg.start([
		"Beyond this door lies the boss",
		"Once you go through, there is no coming back",
		"Press E again to enter…",
	])

	dlg.talk_finished.connect(func() -> void:
		_dialog_open = false
		_confirmed = true
		_prompt.visible = true
		sprite.play("outline")
	)

func _open_sequence() -> void:
	_opened = true
	_prompt.visible = false
	await open()

func _on_door_entered(_rp: Vector2i, _dir: String, body: Node) -> void:
	if not _opened or body.name != "Player": return
	if not next_scene: return

	# Immediately transition to boss scene
	var player: Node = body
	_tree.change_scene_to_packed(next_scene)
	
	# Wait for scene to load
	await _tree.process_frame
	while _tree.current_scene == null:
		await _tree.process_frame
	
	# Reparent player
	_tree.current_scene.add_child(player)
	player.global_position = $Spawnpoint.global_position
