# NutsworthSword.gd  ───────────────────────────────────────────
extends Node2D
class_name NutsworthSword

# ───────────── constants ───────────────────────────────────
const COOLDOWN := 0.25        # seconds before you can re‑press “E”

# ───────────── exported knobs ──────────────────────────────
@export var ui_layer      : CanvasLayer
@export var ant_scene     : PackedScene

@export var lines_before : PackedStringArray = [
	"Now boy, to switch weapons you must press Q! That is how you access your sword!",
	"I believe there is an even more formidable foe for you to test this newfound knowledge!",
	"Ah, sapling, behold that nasty ant!",
	"Your gun won’t even scratch it.",
	"Equip your sword and show it some REAL bark!"
]

@export var lines_after  : PackedStringArray = [
	"Phenomenal swordplay!",
	"The path ahead is clear – it's time for you to venture further down the tree!"
]

@export var lines_during : PackedStringArray = [
	"Remember: only sharp swings harm that pest!",
	"Give it some slashing fury!"
]

# ───────────── cached nodes ────────────────────────────────
@onready var _sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var _prompt : RichTextLabel    = $Prompt

@onready var _door : Door            = get_parent().get_node("DoorN/DoorN")
@onready var ant_spawn_pt : Node2D   = get_parent().get_node("AntSpawnPoint")

# ───────────── internal state ──────────────────────────────
var _dialog_open          := false
var _player_in_range      := false
var _ant_alive            := false
var _ant_defeated         := false
var _dialog_cooldown_left := 0.0        # ← NEW

# ───────────────────────────────────────────────────────────
func _ready() -> void:
	_sprite.play("idle")
	_prompt.visible   = false
	$Area2D.body_entered.connect(_on_entered)
	$Area2D.body_exited .connect(_on_exited)

# ───────────────────────────────────────────────────────────
func _process(delta: float) -> void:             # ← NEW
	if _dialog_cooldown_left > 0.0:
		_dialog_cooldown_left -= delta

# ───────────────────────────────────────────────────────────
# player proximity
func _on_entered(body : Node) -> void:
	if body.name != "Player": return
	_player_in_range = true
	_sprite.play("idle_outline")
	_prompt.global_position = $DialogSpawn.global_position
	_prompt.visible = true

func _on_exited(body : Node) -> void:
	if body.name != "Player": return
	_player_in_range = false
	_sprite.play("idle")
	_prompt.visible = false

# ───────────────────────────────────────────────────────────
# handle “E” / “interact”
func _unhandled_input(event : InputEvent) -> void:
	# block during dialogue *or* while the cool‑down is ticking
	if _dialog_open or _dialog_cooldown_left > 0.0:
		return
	if _player_in_range and event.is_action_pressed("interact"):
		_start_dialogue()

func _start_dialogue() -> void:
	_dialog_open = true
	_prompt.visible = false

	# choose the correct text
	var text : PackedStringArray
	if _ant_defeated:
		text = lines_after
	elif _ant_alive:
		text = lines_during
	else:
		text = lines_before

	# pop the DialogueBox
	var dlg := preload("res://NPCs/Dialog.tscn").instantiate()
	ui_layer.add_child(dlg)
	dlg.start(text)

	dlg.talk_finished.connect(func():
		_dialog_open           = false
		_dialog_cooldown_left  = COOLDOWN          # ← NEW
		_sprite.play("idle")

		if not _ant_alive and not _ant_defeated:
			_spawn_ant()
	)

# ───────────────────────────────────────────────────────────
# spawn & track the ant
func _spawn_ant() -> void:
	if ant_spawn_pt == null:
		push_error("NutsworthSap: ant_spawn_pt is invalid"); return

	var ant := ant_scene.instantiate()
	ant.global_position = ant_spawn_pt.global_position
	get_tree().current_scene.add_child(ant)

	_ant_alive = true
	ant.enemy_defeated.connect(_on_ant_defeated)

func _on_ant_defeated() -> void:
	_ant_alive    = false
	_ant_defeated = true
	if _door: _door.open()
