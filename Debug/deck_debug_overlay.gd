extends CanvasLayer
class_name DeckDebugOverlay

var debug_visible := false
var panel: PanelContainer
var bullet_label: Label
var card_label: Label

func _ready() -> void:
	layer = 100
	_build_ui()

func _build_ui() -> void:
	panel = PanelContainer.new()
	panel.position = Vector2(12, 12)
	panel.visible = false
	add_child(panel)

	var vbox := VBoxContainer.new()
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "DECK DEBUG (F3 to toggle)"
	vbox.add_child(title)

	bullet_label = Label.new()
	vbox.add_child(bullet_label)

	card_label = Label.new()
	vbox.add_child(card_label)

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F3:
		debug_visible = !debug_visible
		panel.visible = debug_visible

func _process(_delta: float) -> void:
	if not debug_visible:
		return
	if is_instance_valid(GlobalData.bullet_deck):
		bullet_label.text = "BulletDeck  draw:%d  discard:%d\n%s" % [
			GlobalData.bullet_deck.draw_pile.size(),
			GlobalData.bullet_deck.discard_pile.size(),
			_count_by_type(GlobalData.bullet_deck.draw_pile, BulletCard.Type)
		]
	if is_instance_valid(GlobalData.card_deck):
		card_label.text = "CardDeck  draw:%d  discard:%d\n%s" % [
			GlobalData.card_deck.draw_pile.size(),
			GlobalData.card_deck.discard_pile.size(),
			_count_by_name(GlobalData.card_deck.draw_pile)
		]

func _count_by_type(pile: Array, type_enum) -> String:
	var counts := {}
	for card in pile:
		counts[card.type] = counts.get(card.type, 0) + 1
	var lines := []
	for key in counts:
		lines.append("  %s: %d" % [type_enum.keys()[key], counts[key]])
	return "\n".join(lines)

func _count_by_name(pile: Array) -> String:
	var counts := {}
	for card in pile:
		counts[card.display_name] = counts.get(card.display_name, 0) + 1
	var lines := []
	for key in counts:
		lines.append("  %s: %d" % [key, counts[key]])
	return "\n".join(lines)
