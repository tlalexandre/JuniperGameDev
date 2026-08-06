extends CanvasLayer
class_name ManaBar

var fill_rect: ColorRect
var label: Label
var bar_width := 200.0

func _ready() -> void:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	GlobalData.mana_bar = self

	var background := ColorRect.new()
	background.color = Color(0.1, 0.1, 0.15, 0.85)
	background.custom_minimum_size = Vector2(bar_width, 20)
	background.size = Vector2(bar_width, 20)
	root.add_child(background)

	fill_rect = ColorRect.new()
	fill_rect.color = Color(0.3, 0.5, 1.0, 1.0)
	fill_rect.size = Vector2(bar_width, 20)
	background.add_child(fill_rect)

	label = Label.new()
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	background.add_child(label)

	await get_tree().process_frame
	var viewport_size = get_viewport().get_visible_rect().size
	background.position = Vector2(24, viewport_size.y - 60)

func bind(mana: PlayerMana) -> void:
	mana.mana_changed.connect(_on_mana_changed)
	_on_mana_changed(mana.current_mana, mana.max_mana)

func _on_mana_changed(current: float, max: float) -> void:
	var frac = clamp(current / max, 0.0, 1.0) if max > 0 else 0.0
	fill_rect.size.x = bar_width * frac
	label.text = "%.1f / %.1f" % [current, max]  # rounding happens ONLY here, display-side
