extends Area2D
class_name Door

@export var direction : String
var room_pos : Vector2i = Vector2i.ZERO
var dungeon  : Node = null
var locked : bool = false

signal door_entered(room_pos : Vector2i, direction : String, body : Node)

func _ready() -> void:
	if direction == "" and name.begins_with("Door"):
		direction = name.substr(4,1)
	print("[Door READY] name:", name, "dir:", direction)
	connect("body_entered", _on_body_entered)

func _on_body_entered(body : Node) -> void:
	if locked:
		print("[Door BLOCKED] Locked: %s" % name)
		return
	print("[Door ENTER] door:", name, "body:", body.name)
	if body.name == "Player":
		emit_signal("door_entered", room_pos, direction, body)

func slam_shut() -> void:
	if $AnimationPlayer:
		$AnimationPlayer.play("slam")
	locked = true
	set_deferred("monitoring", false)  # Prevent trigger

func open_door() -> void:
	if $AnimationPlayer:
		$AnimationPlayer.play("open")
	locked = false
	set_deferred("monitoring", true)
