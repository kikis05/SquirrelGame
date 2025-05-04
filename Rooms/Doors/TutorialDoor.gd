extends Door
class_name TutorialDoor

@export var next_room : PackedScene    # drag the tutorial‑Room‑2 scene here

func _ready() -> void:
	super()
	slam()

func _on_body_entered(body : Node) -> void:
	super._on_body_entered(body)        # keep base behaviour
	if body.name == "Player" and blocker_shape.disabled and next_room:
		get_tree().change_scene_to_packed(next_room)
