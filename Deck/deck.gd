extends Resource
class_name Deck

var draw_pile: Array = []
var discard_pile: Array = []
var exhaust_pile: Array = []

func draw(n: int) -> Array:
	var drawn: Array = []
	for i in n:
		if draw_pile.is_empty():
			_reshuffle()
		if draw_pile.is_empty():
			break
		drawn.append(draw_pile.pop_back())
	return drawn

func discard(cards: Array) -> void:
	discard_pile.append_array(cards)

func exhaust(cards: Array) -> void:
	exhaust_pile.append_array(cards)

func _reshuffle() -> void:
	draw_pile.append_array(discard_pile)
	discard_pile.clear()
	draw_pile.shuffle()
