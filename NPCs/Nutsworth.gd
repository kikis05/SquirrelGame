extends Node2D
class_name Nutsworth

signal talk_finished         # emitted when all lines are done

@export var lines := [
	"Hello old chap, remember me?",
	"Why it's your good ol pal, Acornelius Nutsworth!",
	"Yes, well... to be completely honest...",
	"I have utterly no idea how we got thrown atop this infested tree...",
	"We must’ve gotten ourselves in some sort of conundrum last night! Oh ho ho ho!",
	"And why, I could fight my way down to escape...",
	"But I'm far too old and frail, my best days are long behind me now...",
	"But you on the other hand! Why,you are positively spry for the undertaking!",
	"A mere whippersnapper, yet!",
	"That is why I have decided to teach you in the proper ways of fighting as a gentle squirrel.",
	"Go on ahead! Through the door now."
]

@onready var _sprite : AnimatedSprite2D   = $AnimatedSprite2D
@onready var _prompt : RichTextLabel      = $Prompt
@export var ui_layer : CanvasLayer
@onready var _door :  = get_parent().get_node("DoorN/DoorN")
var _player_in_range := false
var _dialog_open     := false
var _cool_timer : Timer                     
var _can_talk    := true                    


func _ready():
	_sprite.play("idle")
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
	_door.open()
