extends Node

func _ready() -> void:
	var loadout: Array[BulletCard] = []
	var types = [BulletCard.Type.FIRE, BulletCard.Type.ICE, BulletCard.Type.AIR]
	for i in 10:
		var c = BulletCard.new()
		c.type = types[i % types.size()]
		loadout.append(c)

	var barrel := BulletBarrel.new()
	barrel.barrel_capacity = 4
	barrel.reload_time = 0.1 # short for testing, don't want to wait 2s per cycle

	barrel.barrel_changed.connect(func(b): print("barrel_changed -> size: ", b.size()))
	barrel.reload_started.connect(func(): print("reload_started"))
	barrel.reload_finished.connect(func(): print("reload_finished"))

	add_child(barrel) # needs to be in tree for get_tree().create_timer() to work
	barrel.setup(loadout)

	print("--- take_random one at a time until empty ---")
	while not barrel.barrel.is_empty():
		var card = barrel.take_random()
		print("took: ", BulletCard.Type.keys()[card.type], " barrel left: ", barrel.barrel.size())
		barrel.fire(card)

	await get_tree().create_timer(0.3).timeout # let auto-reload from empty barrel finish
	print("after auto-reload, barrel size: ", barrel.barrel.size())

	print("--- take_all ---")
	var all_cards = barrel.take_all()
	print("took all: ", all_cards.size(), " barrel size after: ", barrel.barrel.size())
	for c in all_cards:
		barrel.deck.discard([c]) # simulate firing them all as a shotgun blast
	print("discard_pile size: ", barrel.deck.discard_pile.size())

	print("--- forced reload with barrel non-empty (simulate ability) ---")
	barrel.setup(loadout) # fresh setup, ignore prior state for this check
	print("barrel size before forced reload: ", barrel.barrel.size())
	barrel.reload()
	await get_tree().create_timer(0.3).timeout
	print("barrel size after forced reload: ", barrel.barrel.size(), " total: ", barrel.deck.draw_pile.size() + barrel.deck.discard_pile.size() + barrel.barrel.size())
