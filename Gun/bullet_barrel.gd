extends Node
class_name BulletBarrel

signal barrel_changed(barrel: Array, capacity : int)
signal reload_started
signal reload_finished

@export var barrel_capacity: int = 6
@export var reload_time: float = 2.0

var deck: BulletDeck
var barrel: Array[BulletCard] = []
var reloading := false

func setup(shared_deck: BulletDeck) -> void:
	deck = shared_deck
	barrel.assign(deck.draw(barrel_capacity))
	barrel_changed.emit(barrel, barrel_capacity)

func take_random() -> BulletCard:
	if barrel.is_empty():
		return null
	var idx = randi() % barrel.size()
	var card = barrel[idx]
	barrel.remove_at(idx)
	barrel_changed.emit(barrel, barrel_capacity)
	return card

func take_all() -> Array[BulletCard]:
	var taken = barrel.duplicate()
	barrel.clear()
	barrel_changed.emit(barrel, barrel_capacity)
	return taken

func discard_from_barrel(card: BulletCard) -> void:
	barrel.erase(card)
	deck.discard([card])
	barrel_changed.emit(barrel, barrel_capacity)
	if barrel.is_empty():
		reload()

func reload() -> void:
	if reloading:
		return
	reloading = true
	reload_started.emit()
	if not barrel.is_empty():
		deck.discard(barrel)
		barrel.clear()
	await get_tree().create_timer(reload_time).timeout
	barrel.assign(deck.draw(barrel_capacity))
	barrel_changed.emit(barrel, barrel_capacity)
	reload_finished.emit()
	reloading = false
	
func fire(card: BulletCard) -> void:
	deck.discard([card])
	if barrel.is_empty():
		reload()
