extends Control
class_name CardView

@onready var icon: TextureRect = $Background/ContentContainer/Icon
@onready var card_name: Label = $Background/ContentContainer/TextContainer/CardName
@onready var card_description: Label = $Background/ContentContainer/TextContainer/CardDescription


var _tween: Tween

func _ready() -> void:
	modulate.a = 0.0
	visible = false

func display(card: CardResource) -> void:
	icon.texture = card.icon
	card_name.text = card.display_name
	card_description.text = card.description

func play_appear(duration: float = 0.25) -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	visible = true
	modulate.a = 0.0
	scale = Vector2(0.85, 0.85)
	pivot_offset = size / 2.0
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 1.0, duration)
	_tween.parallel().tween_property(self, "scale", Vector2.ONE, duration)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func play_disappear(duration: float = 0.3) -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 0.0, duration)
	_tween.parallel().tween_property(self, "scale", Vector2(0.85, 0.85), duration)
	_tween.tween_callback(func(): visible = false)
