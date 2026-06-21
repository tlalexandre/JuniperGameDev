extends Bullet

var double_dmg = bullet_dmg * 2

func _ready() -> void:
	speed = 1200
	bullet_dmg = 1

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):	
		var dir = (body.global_position - global_position).normalized()
		body.apply_status(body.Status.DMG_ON_TICK, Vector2.ZERO, 0, 0.05)
		if body.is_in_group("rat"):
			body.take_damage(double_dmg)
		else:
			body.take_damage(bullet_dmg)
		queue_free()
