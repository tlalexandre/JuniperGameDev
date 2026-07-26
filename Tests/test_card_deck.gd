extends Node

func _ready() -> void:
	var deck = CardDeck.new()

	var types = [
		AbilityCard.Type.PLACEHOLDER_A, AbilityCard.Type.PLACEHOLDER_B,
		AbilityCard.Type.PLACEHOLDER_C, AbilityCard.Type.PLACEHOLDER_D
	]
	for i in 8:
		var c = AbilityCard.new()
		c.type = types[i % types.size()]
		deck.draw_pile.append(c)

	print("Initial draw_pile size: ", deck.draw_pile.size())

	var batch1 = deck.draw(4)
	print("Drew: ", batch1.map(func(c): return AbilityCard.Type.keys()[c.type]))
	deck.discard(batch1)

	var batch2 = deck.draw(4)
	print("Drew: ", batch2.map(func(c): return AbilityCard.Type.keys()[c.type]))
	deck.discard(batch2)

	var batch3 = deck.draw(4)
	print("Drew (should trigger reshuffle): ", batch3.map(func(c): return AbilityCard.Type.keys()[c.type]))
	print("Final draw_pile size: ", deck.draw_pile.size())
	print("Final discard_pile size: ", deck.discard_pile.size())
