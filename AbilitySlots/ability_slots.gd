extends Node
class_name AbilitySlots

signal slots_changed(slots: Array, capacity: int)
signal slot_used(index: int, card: AbilityCard)
signal slot_use_failed(index: int, card: AbilityCard)

@export var slot_count: int = 4

var deck: CardDeck
var mana: PlayerMana
var slots: Array[AbilityCard] = []

func setup(shared_deck: CardDeck, mana_source: PlayerMana) -> void:
	deck = shared_deck
	mana = mana_source
	slots.resize(slot_count)
	var drawn = deck.draw(slot_count)
	for i in slot_count:
		slots[i] = drawn[i] if i < drawn.size() else null
	slots_changed.emit(slots, slot_count)

func can_use(index: int) -> bool:
	if index < 0 or index >= slot_count or slots[index] == null:
		return false
	return mana.can_afford(slots[index].mana_cost)

func use(index: int) -> bool:
	if index < 0 or index >= slot_count or slots[index] == null:
		return false
	if not can_use(index):
		slot_use_failed.emit(index, slots[index])
		return false
	var card = slots[index]
	mana.spend(card.mana_cost)
	deck.discard([card])
	var drawn = deck.draw(1)
	slots[index] = drawn[0] if not drawn.is_empty() else null
	slot_used.emit(index, card)
	slots_changed.emit(slots, slot_count)
	return true
