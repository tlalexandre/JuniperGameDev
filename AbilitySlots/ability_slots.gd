extends Node
class_name AbilitySlots

signal slots_changed(slots: Array, capacity: int)
signal slot_used(index: int, card: AbilityCard)
signal slot_ready(index: int)

@export var slot_count: int = 4

var slots: Array[AbilityCard] = []
var cooldown_remaining: Array[float] = []

func _ready() -> void:
	slots.resize(slot_count)
	cooldown_remaining.resize(slot_count)
	for i in slot_count:
		cooldown_remaining[i] = 0.0

func setup(cards: Array) -> void:
	slots.resize(slot_count)
	cooldown_remaining.resize(slot_count)
	for i in slot_count:
		slots[i] = cards[i] if i < cards.size() else null
		cooldown_remaining[i] = 0.0
	slots_changed.emit(slots, slot_count)

func _process(delta: float) -> void:
	for i in slot_count:
		if cooldown_remaining[i] > 0.0:
			cooldown_remaining[i] = max(0.0, cooldown_remaining[i] - delta)
			if cooldown_remaining[i] == 0.0:
				slot_ready.emit(i)

func can_use(index: int) -> bool:
	if index < 0 or index >= slot_count:
		return false
	if slots[index] == null:
		return false
	return cooldown_remaining[index] <= 0.0

func use(index: int) -> bool:
	if not can_use(index):
		return false
	var card = slots[index]
	cooldown_remaining[index] = card.cooldown
	slot_used.emit(index, card)
	return true

func cooldown_fraction(index: int) -> float:
	if slots[index] == null or slots[index].cooldown <= 0.0:
		return 0.0
	return cooldown_remaining[index] / slots[index].cooldown
