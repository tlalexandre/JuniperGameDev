extends Bullet

var double_dmg = bullet_dmg * 2
var knockback_force = 500
func _ready() -> void:
	bullet_color = Color(0.7, 0.95, 1.0) 
	super._ready()


func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):	
		var dir = (body.global_position - global_position).normalized()
		body.apply_status(body.Status.KNOCKBACK, dir, 800, 0.3)
		if body.is_in_group("ghost"):
			body.take_damage(double_dmg)
		else:
			body.take_damage(bullet_dmg)
		queue_free()
