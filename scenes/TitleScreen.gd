extends Control

@onready var start_btn     = $StartButton
@onready var start_hover_s = $StartButton/HoverSound
@onready var exit_btn      = $ExitButton
@onready var exit_hover_s  = $ExitButton/HoverSound

func _ready() -> void:
	start_btn.pressed.connect(_on_start_pressed)
	exit_btn.pressed.connect(_on_exit_pressed)

	start_btn.mouse_entered.connect(start_hover_s.play)
	exit_btn.mouse_entered.connect(exit_hover_s.play)

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/TutorialLevel.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
