extends Node
class_name AbilitySlots

signal slots_changed(slots: Array, capacity: int)
signal slot_used(index: int, card: AbilityCard)
signal slot_ready(index: int, card: AbilityCard)

@export var slot_count: int = 4

var deck: CardDeck
var slots: Array[AbilityCard] = []
var cooldown_remaining: Array[float] = []
var cooldown_duration: Array[float] = []  # needed for HUD fraction, since the card is gone while cooling

func _ready() -> void:
	slots.resize(slot_count)
	cooldown_remaining.resize(slot_count)
	cooldown_duration.resize(slot_count)
	for i in slot_count:
		cooldown_remaining[i] = 0.0
		cooldown_duration[i] = 0.0

func setup(shared_deck: CardDeck) -> void:
	deck = shared_deck
	slots.resize(slot_count)
	cooldown_remaining.resize(slot_count)
	cooldown_duration.resize(slot_count)
	var drawn = deck.draw(slot_count)
	for i in slot_count:
		slots[i] = drawn[i] if i < drawn.size() else null
		cooldown_remaining[i] = 0.0
		cooldown_duration[i] = 0.0
	slots_changed.emit(slots, slot_count)

func _process(delta: float) -> void:
	for i in slot_count:
		if slots[i] == null and cooldown_remaining[i] <= 0.0:
			_try_refill(i)
		elif cooldown_remaining[i] > 0.0:
			cooldown_remaining[i] = max(0.0, cooldown_remaining[i] - delta)

func _try_refill(index: int) -> void:
	var drawn = deck.draw(1)
	if drawn.is_empty():
		return  # deck fully empty, both piles - retries next frame
	slots[index] = drawn[0]
	cooldown_duration[index] = 0.0
	slot_ready.emit(index, drawn[0])
	slots_changed.emit(slots, slot_count)

func can_use(index: int) -> bool:
	if index < 0 or index >= slot_count:
		return false
	return slots[index] != null

func use(index: int) -> bool:
	if not can_use(index):
		return false
	var card = slots[index]
	deck.discard([card])
	slots[index] = null
	cooldown_remaining[index] = card.cooldown
	cooldown_duration[index] = card.cooldown
	slot_used.emit(index, card)
	slots_changed.emit(slots, slot_count)
	return true

func cooldown_fraction(index: int) -> float:
	if cooldown_duration[index] <= 0.0:
		return 0.0
	return cooldown_remaining[index] / cooldown_duration[index]
