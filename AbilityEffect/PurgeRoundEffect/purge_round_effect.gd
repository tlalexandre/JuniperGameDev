class_name PurgeRoundEffect
extends AbilityEffect

func execute() -> void:
	var barrel := GlobalData.active_barrel
	if barrel and not barrel.barrel.is_empty():
		var idx := randi() % barrel.barrel.size()
		var card := barrel.barrel[idx]
		barrel.discard_and_redraw_from_barrel(card)
	queue_free()
