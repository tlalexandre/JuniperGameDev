extends CanvasLayer
class_name AbilityHud

@onready var key_icons: Array[TextureRect] = [
	$Root/HBoxContainer/Ability1/KeySlot/TextureRect,
	$Root/HBoxContainer/Ability2/KeySlot/TextureRect,
	$Root/HBoxContainer/Ability3/KeySlot/TextureRect,
	$Root/HBoxContainer/Ability4/KeySlot/TextureRect
]
@onready var card_views: Array[CardView] = [
	$Root/HBoxContainer/Ability1/CardView,
	$Root/HBoxContainer/Ability2/CardView,
	$Root/HBoxContainer/Ability3/CardView,
	$Root/HBoxContainer/Ability4/CardView
]

var ability_slots: AbilitySlots
var slot_tweens: Array[Tween] = []

func _ready() -> void:
	GlobalData.ability_hud = self
	slot_tweens.resize(card_views.size())

func bind(slots: AbilitySlots) -> void:
	ability_slots = slots
	ability_slots.slots_changed.connect(_on_slots_changed)
	ability_slots.slot_used.connect(_on_slot_used)
	_on_slots_changed(ability_slots.slots, ability_slots.slot_count)

func _on_slots_changed(slots: Array, capacity: int) -> void:
	for i in capacity:
		var card: AbilityCard = slots[i] if i < slots.size() else null
		if card == null:
			key_icons[i].texture = null
			card_views[i].visible = false
		else:
			key_icons[i].texture = card.icon
			card_views[i].display(card)
			card_views[i].modulate = Color(1, 1, 1, 1)
			card_views[i].visible = true

func _on_slot_used(index: int, used_card: AbilityCard) -> void:
	var view := card_views[index]
	var new_card: AbilityCard = ability_slots.slots[index]  # already the redrawn card by this point

	if slot_tweens[index] and slot_tweens[index].is_valid():
		slot_tweens[index].kill()

	var tween := create_tween()
	slot_tweens[index] = tween
	tween.tween_property(view, "modulate", Color(0.35, 0.35, 0.35, 1.0), 0.12)
	tween.tween_callback(func():
		key_icons[index].texture = new_card.icon if new_card else null
		if new_card:
			view.display(new_card)
			view.visible = true
		else:
			view.visible = false
	)
	tween.tween_property(view, "modulate", Color(1, 1, 1, 1), 0.25)
