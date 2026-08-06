extends CanvasLayer
class_name CardRewardPanel

signal card_chosen(card: CardResource)
signal reward_skipped()

@onready var card_views: Array[CardView] = [
	$Root/VBoxContainer/CardRow/Slot1/CardView,
	$Root/VBoxContainer/CardRow/Slot2/CardView,
	$Root/VBoxContainer/CardRow/Slot3/CardView
]
@onready var take_buttons: Array[Button] = [
	$Root/VBoxContainer/CardRow/Slot1/TakeButton,
	$Root/VBoxContainer/CardRow/Slot2/TakeButton,
	$Root/VBoxContainer/CardRow/Slot3/TakeButton
]
@onready var skip_button: Button = $Root/VBoxContainer/SkipButton

var offered_cards: Array[CardResource] = []

func _ready() -> void:
	visible = false
	for i in take_buttons.size():
		take_buttons[i].pressed.connect(_on_take_pressed.bind(i))
	skip_button.pressed.connect(_on_skip_pressed)

func offer(cards: Array[CardResource]) -> void:
	offered_cards = cards
	for i in card_views.size():
		if i < cards.size():
			card_views[i].display(cards[i])
			card_views[i].visible = true
			take_buttons[i].disabled = false
		else:
			card_views[i].visible = false
			take_buttons[i].disabled = true

	visible = true
	get_tree().paused = true
	for cv in card_views:
		if cv.visible:
			cv.play_appear()

func _on_take_pressed(index: int) -> void:
	var chosen := offered_cards[index]
	_close()
	card_chosen.emit(chosen)

func _on_skip_pressed() -> void:
	_close()
	reward_skipped.emit()

func _close() -> void:
	get_tree().paused = false
	visible = false
