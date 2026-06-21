extends Bullet

var double_dmg = bullet_dmg * 2
var knockback_force = 500

func _ready() -> void:
	rotation = target_position.angle() + deg_to_rad(90)
	
	bullet_dmg = 5
