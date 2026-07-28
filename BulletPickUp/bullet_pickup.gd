extends Area2D

var bullet_type  # the PackedScene type dropped by the chest

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
const BULLET_AIR_SPRITE = preload("uid://c2fpl7j1ftbo5")
const BULLET_ELECTRICITY_SPRITE = preload("uid://cxxpfav6iu0gs")
const BULLET_FIRE_SPRITE = preload("uid://dgaj283s7c65q")
const BULLET_ICE_SPRITE = preload("uid://cb5q13cpkbl8g")
const BULLET_POISON_SPRITE = preload("uid://ckpk0v8clsal")
const BULLET_SPRITE = preload("uid://c8n73wruw4a77")

const BULLET_SPRITES = {
	"BULLET":      BULLET_SPRITE,
	"AIR":         BULLET_AIR_SPRITE,
	"POISON":      BULLET_POISON_SPRITE,
	"ELECTRICITY": BULLET_ELECTRICITY_SPRITE,
	"FIRE":        BULLET_FIRE_SPRITE,
	"ICE":         BULLET_ICE_SPRITE,
}

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func setup(type) -> void:
	bullet_type = type
	var sf := SpriteFrames.new()
	sf.add_animation("idle")
	sf.set_animation_loop("idle", true)
	sf.set_animation_speed("idle", 8.0)
	var key = _get_key_for_type(type)
	var texture = BULLET_SPRITES[key]
	for i in 4:
		var at := AtlasTexture.new()
		at.atlas = texture
		at.region = Rect2(i * 32, 0, 32, 32)
		sf.add_frame("idle", at)
	anim.sprite_frames = sf
	anim.play("idle")

func _get_key_for_type(type) -> String:
	if type == GlobalData.AIR: return "AIR"
	if type == GlobalData.POISON: return "POISON"
	if type == GlobalData.ELECTRICITY: return "ELECTRICITY"
	if type == GlobalData.FIRE: return "FIRE"
	if type == GlobalData.ICE: return "ICE"
	return "BULLET"

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		var card := BulletCard.new()
		card.type = _type_to_bullet_card_type(bullet_type)
		card.scene = bullet_type
		GlobalData.bullet_deck.draw_pile.append(card)
		GlobalData.bullet_deck.draw_pile.shuffle()
		queue_free()

func _type_to_bullet_card_type(scene: PackedScene) -> BulletCard.Type:
	if scene == GlobalData.AIR: return BulletCard.Type.AIR
	if scene == GlobalData.POISON: return BulletCard.Type.POISON
	if scene == GlobalData.ELECTRICITY: return BulletCard.Type.ELECTRICITY
	if scene == GlobalData.FIRE: return BulletCard.Type.FIRE
	if scene == GlobalData.ICE: return BulletCard.Type.ICE
	return BulletCard.Type.BASIC
