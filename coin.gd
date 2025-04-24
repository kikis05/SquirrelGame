extends Area2D

@export var speed := 150.0
var player: Node = null
var attracted := false

func _ready():
	pass

func attract_to_player(p: Node):
	player = p
	attracted = true

func _physics_process(delta: float) -> void:
	if attracted and player != null:
		global_position = global_position.move_toward(player.global_position, speed * delta)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		queue_free()
