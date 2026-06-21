extends Bullet

var double_dmg = bullet_dmg * 2

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		body.apply_status(body.Status.STUN, Vector2.ZERO,0.0, 1.0)
		if body.is_in_group("candle"):
			body.take_damage(double_dmg)
		else:
			body.take_damage(bullet_dmg)
		
