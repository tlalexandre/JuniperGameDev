# ExplosionVFX.gd
extends AnimatedSprite2D

func _ready() -> void:
	play("explode")
	await animation_finished
	queue_free()
