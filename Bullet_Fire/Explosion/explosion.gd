# ExplosionVFX.gd
extends AnimatedSprite2D
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	play("explode")
	audio.play()
	await animation_finished
	queue_free()
