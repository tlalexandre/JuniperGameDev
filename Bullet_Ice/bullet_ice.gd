extends Bullet

var double_dmg = bullet_dmg * 2
var knockback_force = 500
func _ready() -> void:
	speed = 1200
	bullet_dmg = 5
