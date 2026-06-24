class_name IceBullet
extends Bullet

var bounces_remaining: int = 3
var double_dmg

func _ready() -> void:
	bullet_color = Color(0.3, 0.75, 1.0)
	super._ready()
	double_dmg = bullet_dmg * 2


func _physics_process(delta: float) -> void:
	var collision = move_and_collide(target_position * speed * delta)
	if collision:
		if collision.get_collider().is_in_group("enemies") and collision.get_collider().is_in_group("candle"):
			collision.get_collider().take_damage(double_dmg)
			queue_free()
		elif collision.get_collider().is_in_group("enemies"):
			collision.get_collider().take_damage(bullet_dmg)
			queue_free()
		else:
			target_position = Vector2(-target_position.x, target_position.y) if abs(collision.get_normal().x) > 0.5 else Vector2(target_position.x, -target_position.y)
			rotation = target_position.angle() + deg_to_rad(90)
			position += collision.get_normal() * 2
			bounces_remaining -= 1
			if bounces_remaining <= 0:
				queue_free()
