extends Node

func _ready() -> void:
	var cards: Array[AbilityCard] = []
	var defs = [["Dash Blast", 1.0], ["Barrier", 0.6], ["Overcharge", 1.5], ["Time Slip", 0.4]]
	for d in defs:
		var c = AbilityCard.new()
		c.display_name = d[0]
		c.cooldown = d[1]
		cards.append(c)

	var slots := AbilitySlots.new()
	slots.slot_count = 4
	slots.slot_used.connect(func(i, card): print("used slot ", i, " -> ", card.display_name))
	slots.slot_ready.connect(func(i): print("slot ", i, " ready again"))

	add_child(slots) # needs to be in tree for _process to run
	slots.setup(cards)

	print("--- fire all 4 slots ---")
	for i in 4:
		print("can_use(", i, ") before: ", slots.can_use(i))
		slots.use(i)
		print("can_use(", i, ") after: ", slots.can_use(i))

	print("--- using an already-cooling slot should fail ---")
	print("use(0) while cooling: ", slots.use(0))

	print("--- wait for shortest cooldown (Time Slip, 0.4s) ---")
	await get_tree().create_timer(0.5).timeout
	print("can_use(3) after 0.5s: ", slots.can_use(3))
	print("can_use(0) after 0.5s (1.0s cd, should still be false): ", slots.can_use(0))

	print("--- wait for the rest ---")
	await get_tree().create_timer(1.2).timeout
	for i in 4:
		print("can_use(", i, ") final: ", slots.can_use(i))
