extends Node2D
class_name Ladder

@export var next_scene      : PackedScene
@export var interact_action : String = "interact"

@onready var _sprite : AnimatedSprite2D = $Sprite
@onready var _prompt : RichTextLabel    = $Prompt
@onready var _area   : Area2D           = $Area2D

var _player_in := false
var _busy      := false
var _player    : Node                     # cached once touched
# ────────────────────────────────────────────────────────────────
func _ready() -> void:
	add_to_group("room_deletables")
	_sprite.play("default")
	_prompt.visible = false
	_area.body_entered.connect(_on_body_enter)
	_area.body_exited .connect(_on_body_exit)

func _on_body_enter(body : Node) -> void:
	if body.name != "Player" or _busy: return
	_player_in = true
	_sprite.play("outline")
	_prompt.visible = true
	_player = body

func _on_body_exit(body : Node) -> void:
	if body.name != "Player" or _busy: return
	_player_in = false
	_sprite.play("default")
	_prompt.visible = false

func _unhandled_input(event : InputEvent) -> void:
	if _busy or not _player_in: return
	if event.is_action_pressed(interact_action):
		_start_climb()

func _start_climb() -> void:
	_busy = true
	_prompt.visible = false
	var tree = get_tree()

	if _player:
		# Save player stats
		GameState.player_stats.max_health     = _player.max_health
		GameState.player_stats.current_health = _player.current_health
		GameState.player_stats.coins          = _player.coins
		GameState.player_stats.gun_attack     = _player.get_gun_attack()
		GameState.player_stats.gun_speed      = _player.get_gun_speed()
		GameState.player_stats.sword_attack   = _player.get_sword_attack()
		GameState.player_stats.speed          = _player.speed

		# Hide player
		_player.visible = false
		_player.set_physics_process(false)
		_player.set_process(false)

	_sprite.play("climb")
	await _sprite.animation_finished

	# Fade to black
	TransitionScreen.fade_out()
	await TransitionScreen.fade_out_finished

	if next_scene:
		tree.change_scene_to_packed(next_scene)
