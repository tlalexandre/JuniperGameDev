class_name OverchargeEffect
extends AbilityEffect

const DAMAGE_PER_BULLET := 4
const OVERCHARGE_BULLET_SCENE := preload("res://Bullet/bullet.tscn")

func execute() -> void:
	var barrel := GlobalData.active_barrel
	if barrel == null or barrel.barrel.is_empty():
		queue_free()
		return

	var cards = barrel.take_all()
	var new_bullet = OVERCHARGE_BULLET_SCENE.instantiate()
	new_bullet.position = caster.global_position
	new_bullet.target_position = (caster.get_global_mouse_position() - caster.global_position).normalized()
	new_bullet.bullet_dmg = DAMAGE_PER_BULLET * cards.size()
	GlobalData.world.add_child(new_bullet)

	for card in cards:
		barrel.fire(card)

	queue_free()
