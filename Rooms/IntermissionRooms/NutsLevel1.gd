extends Node2D
class_name NutsworthHole

signal talk_finished         # emitted when all lines are done

@export var lines := [
	"Incredible! Simply Incredible!",
	"We still have one more level to go though...",
	"But after seeing what you are capable of, I have not doubts in your capability to succeed!"
]

@onready var _sprite : AnimatedSprite2D   = $AnimatedSprite2D
@onready var _prompt : RichTextLabel      = $Prompt
@export var ui_layer : CanvasLayer
@onready var _doorW :  = get_parent().get_node("DoorW/DoorW")
var _player_in_range := false
var _dialog_open     := false
var _cool_timer : Timer                     
var _can_talk    := true                    


func _ready():
	$Area2D.body_entered.connect(_on_entered)
	$Area2D.body_exited.connect(_on_exited)
	_prompt.visible = false
	_cool_timer = Timer.new()
	_cool_timer.one_shot = true
	add_child(_cool_timer)
	_cool_timer.timeout.connect(func(): _can_talk = true)


func _on_entered(body):
	if body.name != "Player": return
	_player_in_range = true
	_sprite.play("idle_outline")
	_prompt.global_position = $DialogSpawn.global_position
	_prompt.visible = true


func _on_exited(body):
	if body.name != "Player": return
	_player_in_range = false
	_sprite.play("idle")
	_prompt.visible = false


func _unhandled_input(event):
	if _dialog_open or not _can_talk:
		return
	if _player_in_range and event.is_action_pressed("interact"):
		_start_dialogue()


func _start_dialogue():
	_dialog_open = true
	_can_talk    = false
	_prompt.visible = false

	var dlg = preload("res://NPCs/Dialog.tscn").instantiate()
	ui_layer.add_child(dlg)
	dlg.start(lines)

	# When DialogueBox dies it bubbles talk_finished back to us
	dlg.talk_finished.connect(func():
		_dialog_open = false
		_sprite.play("idle")
		emit_signal("talk_finished")
		_on_dialogue_finished()
	)

func _on_dialogue_finished() -> void:
	_dialog_open = false
	_sprite.play("idle")
