extends Node
class_name PlayerMana

signal mana_changed(current: float, max: float)

@export var max_mana: float = 5.0
@export var regen_per_second: float = 0.5

var current_mana: float

func _ready() -> void:
	current_mana = max_mana
	mana_changed.emit(current_mana, max_mana)

func _process(delta: float) -> void:
	if current_mana < max_mana:
		current_mana = min(max_mana, current_mana + regen_per_second * delta)
		mana_changed.emit(current_mana, max_mana)

func can_afford(cost: float) -> bool:
	return current_mana >= cost

func spend(cost: float) -> bool:
	if not can_afford(cost):
		return false
	current_mana -= cost
	mana_changed.emit(current_mana, max_mana)
	return true
