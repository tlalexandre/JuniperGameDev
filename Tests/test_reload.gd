extends Node

var deck: BulletDeck
var barrel: Array[BulletCard] = []
var barrel_capacity: int = 4

func _ready() -> void:
	_setup_deck(10) # loadout bigger than capacity, per your "more bullets than gun capacity" case
	_run_all_scenarios()

func _setup_deck(pool_size: int) -> void:
	deck = BulletDeck.new()
	var types = [BulletCard.Type.FIRE, BulletCard.Type.ICE, BulletCard.Type.AIR]
	for i in pool_size:
		var c = BulletCard.new()
		c.type = types[i % types.size()]
		deck.draw_pile.append(c)
	deck.draw_pile.shuffle()
	barrel.clear()

func _reload() -> void:
	if not barrel.is_empty():
		deck.discard(barrel)
		barrel.clear()
	barrel.assign(deck.draw(barrel_capacity))

func _fire_one() -> BulletCard:
	if barrel.is_empty():
		return null
	var card = barrel.pop_front()
	deck.discard([card])
	return card

func _total() -> int:
	return deck.draw_pile.size() + deck.discard_pile.size() + barrel.size()

func _run_all_scenarios() -> void:
	print("--- Scenario 1: fire all, then reload ---")
	_reload()
	for i in barrel_capacity:
		_fire_one()
	print("barrel: ", barrel.size(), " discard: ", deck.discard_pile.size(), " total: ", _total())
	_reload()
	print("after reload -> barrel: ", barrel.size(), " draw: ", deck.draw_pile.size(), " discard: ", deck.discard_pile.size(), " total: ", _total())

	print("--- Scenario 2: forced reload with partial barrel ---")
	_fire_one()
	_fire_one() # fire 2 of the 4 just loaded
	print("barrel before forced reload: ", barrel.size())
	_reload()
	print("barrel: ", barrel.size(), " draw: ", deck.draw_pile.size(), " discard: ", deck.discard_pile.size(), " total: ", _total())

	print("--- Scenario 3: repeated fire+reload cycles ---")
	for cycle in 5:
		for i in barrel.size():
			_fire_one()
		_reload()
		print("cycle ", cycle, " -> total: ", _total(), " (should always be 10)")

	print("--- Scenario 4: force-reload twice with no firing ---")
	_reload()
	var b1 = barrel.size()
	_reload()
	var b2 = barrel.size()
	print("reload1 barrel: ", b1, " reload2 barrel: ", b2, " total: ", _total())
