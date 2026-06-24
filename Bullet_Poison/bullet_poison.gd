extends Bullet

var double_dmg

func _ready() -> void:
	bullet_color = Color(0.45, 1.0, 0.2)
	super._ready()
	double_dmg = bullet_dmg * 2
	
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		if body.is_in_group("rat"):
			body.apply_status(body.Status.DMG_ON_TICK, Vector2.ZERO, 0, 6)
			body.take_damage(double_dmg)
		else:
			body.apply_status(body.Status.DMG_ON_TICK, Vector2.ZERO, 0, 3)
			body.take_damage(bullet_dmg)
		queue_free()
