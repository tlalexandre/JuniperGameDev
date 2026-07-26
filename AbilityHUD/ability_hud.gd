extends CanvasLayer
class_name AbilityHud

const KEY_LABELS = ["Q", "E", "C", "V"]

var slot_panels: Array[Panel] = []
var slot_icons: Array[TextureRect] = []
var slot_cooldown_overlays: Array[ColorRect] = []
var slot_key_labels: Array[Label] = []
var slot_name_labels: Array[Label] = []

var ability_slots: AbilitySlots

func _ready() -> void:
	_build_ui()
	GlobalData.ability_hud = self

func _build_ui() -> void:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	var container := HBoxContainer.new()
	container.add_theme_constant_override("separation", 12)
	root.add_child(container)

	for i in 4:
		var panel := Panel.new()
		panel.custom_minimum_size = Vector2(64, 64)
		container.add_child(panel)
		slot_panels.append(panel)

		var icon := TextureRect.new()
		icon.set_anchors_preset(Control.PRESET_FULL_RECT)
		icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		panel.add_child(icon)
		slot_icons.append(icon)

		var overlay := ColorRect.new()
		overlay.color = Color(0, 0, 0, 0.75)
		overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		overlay.size = Vector2(64, 0)
		overlay.position = Vector2.ZERO
		panel.add_child(overlay)
		slot_cooldown_overlays.append(overlay)

		var key_label := Label.new()
		key_label.text = KEY_LABELS[i]
		key_label.position = Vector2(4, 2)
		panel.add_child(key_label)
		slot_key_labels.append(key_label)

		var name_label := Label.new()
		name_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.add_theme_font_size_override("font_size", 10)
		panel.add_child(name_label)
		slot_name_labels.append(name_label)

	# position after one frame, once container.size is known
	await get_tree().process_frame
	var viewport_size = get_viewport().get_visible_rect().size
	container.position = Vector2(
		(viewport_size.x - container.size.x) / 2.0,
		viewport_size.y - container.size.y - 24
	)

func bind(slots: AbilitySlots) -> void:
	ability_slots = slots
	ability_slots.slots_changed.connect(_on_slots_changed)
	_on_slots_changed(ability_slots.slots, ability_slots.slot_count)

func _on_slots_changed(slots: Array, capacity: int) -> void:
	for i in capacity:
		var card: AbilityCard = slots[i] if i < slots.size() else null
		if card == null:
			slot_icons[i].texture = null
			slot_name_labels[i].text = ""
		else:
			slot_icons[i].texture = card.icon
			slot_name_labels[i].text = card.display_name

func _process(_delta: float) -> void:
	if ability_slots == null:
		return
	for i in ability_slots.slot_count:
		var frac = ability_slots.cooldown_fraction(i)
		var h = slot_panels[i].size.y * frac
		slot_cooldown_overlays[i].size = Vector2(slot_panels[i].size.x, h)
		slot_cooldown_overlays[i].position.y = slot_panels[i].size.y - h
