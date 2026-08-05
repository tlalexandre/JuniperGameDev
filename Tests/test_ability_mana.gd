extends Node

func _ready() -> void:
	var deck := CardDeck.new()
	var defs = [["Dash Blast", 2.0], ["Barrier", 1.0], ["Overcharge", 4.0], ["Time Slip", 1.5]]
	for d in defs:
		var c = AbilityCard.new()
		c.display_name = d[0]
		c.mana_cost = d[1]
		deck.draw_pile.append(c)

	var mana := PlayerMana.new()
	mana.max_mana = 5.0
	mana.regen_per_second = 1.0
	add_child(mana)

	var slots := AbilitySlots.new()
	slots.slot_count = 4
	slots.slot_used.connect(func(i, c): print("used slot ", i, " -> ", c.display_name, " (cost ", c.mana_cost, ")  mana now: ", mana.current_mana))
	slots.slot_use_failed.connect(func(i, c): print("FAILED slot ", i, " -> ", c.display_name, " (cost ", c.mana_cost, ", have ", mana.current_mana, ")"))
	add_child(slots)
	slots.setup(deck, mana)

	print("--- mana starts at ", mana.current_mana, "/", mana.max_mana, " ---")
	for i in 4:
		print("slot ", i, ": ", slots.slots[i].display_name if slots.slots[i] else "null")

	print("--- try to use all 4 (total cost 8.5, only have 5) ---")
	var failed_index := -1
	for i in 4:
		if not slots.use(i):
			failed_index = i

	print("--- wait 3s for regen (+3 mana) ---")
	await get_tree().create_timer(3.0).timeout
	print("mana after regen: ", mana.current_mana)
	print("retry the slot that actually failed (index ", failed_index, "): ", slots.use(failed_index))
