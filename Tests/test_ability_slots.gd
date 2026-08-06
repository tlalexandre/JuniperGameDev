extends Node

func _ready() -> void:
	# Build a small CardDeck - 4 cards, one per slot, so the first draw is deterministic
	var deck := CardDeck.new()
	var defs = [["Dash Blast", 1.0], ["Barrier", 0.6], ["Overcharge", 1.5], ["Time Slip", 0.4]]
	for d in defs:
		var c = AbilityCard.new()
		c.display_name = d[0]
		c.cooldown = d[1]
		deck.draw_pile.append(c)

	var slots := AbilitySlots.new()
	slots.slot_count = 4
	slots.slot_used.connect(func(i, card): print("used slot ", i, " -> ", card.display_name))
	slots.slot_ready.connect(func(i, card): print("slot ", i, " refilled -> ", card.display_name))

	add_child(slots)
	slots.setup(deck)

	print("--- initial state ---")
	print("draw_pile: ", deck.draw_pile.size(), "  discard_pile: ", deck.discard_pile.size())
	for i in 4:
		print("slot ", i, ": ", slots.slots[i].display_name if slots.slots[i] else "null")

	print("--- use slot 0 (Dash Blast style, 1.0s cd) ---")
	print("can_use(0) before: ", slots.can_use(0))
	slots.use(0)
	print("can_use(0) right after use: ", slots.can_use(0))
	print("slot 0 contents right after use: ", slots.slots[0])  # should be null - discarded, not swapped
	print("draw_pile: ", deck.draw_pile.size(), "  discard_pile: ", deck.discard_pile.size())

	print("--- use slot 3 (Time Slip style, 0.4s cd - shortest) ---")
	slots.use(3)
	print("draw_pile: ", deck.draw_pile.size(), "  discard_pile: ", deck.discard_pile.size())

	print("--- wait 0.5s: slot 3 should refill, slot 0 should not yet ---")
	await get_tree().create_timer(0.5).timeout
	print("slot 3 contents: ", slots.slots[3].display_name if slots.slots[3] else "null")
	print("slot 0 contents (should still be null, 1.0s cd not elapsed): ", slots.slots[0])
	print("can_use(3) after refill: ", slots.can_use(3))

	print("--- wait 0.6s more (t=1.1s total): slot 0 should now be refilled ---")
	await get_tree().create_timer(0.6).timeout
	print("slot 0 contents: ", slots.slots[0].display_name if slots.slots[0] else "null")
	print("can_use(0): ", slots.can_use(0))
	print("final draw_pile: ", deck.draw_pile.size(), "  discard_pile: ", deck.discard_pile.size())
