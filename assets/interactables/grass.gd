extends Area2D

@onready var sense_area = $CollisionShape2D
@onready var animator = $AnimatedSprite2D

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player") or area.is_in_group("player_weapon"):
		animator.play("moved")

func _on_animated_sprite_2d_animation_finished() -> void:
	if animator.animation == "moved":
		animator.play("idle")
