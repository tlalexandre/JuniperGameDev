class_name SparkBoltEffect
extends AbilityEffect

const BONUS_DAMAGE := 3

func execute() -> void:
	GlobalData.queue_shot_modifier(func(bullet): bullet.bullet_dmg += BONUS_DAMAGE)
	queue_free()
