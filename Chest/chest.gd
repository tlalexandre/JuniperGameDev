extends StaticBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var area: Area2D = $Area2D
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
const CHEST = preload("uid://dw06pllyddjp6")
const REWARD_PANEL_SCENE = preload("res://UI/TakeSkipRewardPanel/CardRewardPanel.tscn")
enum BulletOverride { RANDOM, BASIC, AIR, POISON, ELECTRICITY, FIRE, ICE }
@export var bullet_override: BulletOverride = BulletOverride.RANDOM

var opened := false

func _ready() -> void:
	anim.sprite_frames = _build_frames()
	anim.play("idle")
	area.body_entered.connect(_on_body_entered)
	anim.animation_finished.connect(_on_animation_finished)

func _build_frames() -> SpriteFrames:
	var sf := SpriteFrames.new()
	var texture := CHEST

	sf.add_animation("idle")
	sf.set_animation_loop("idle", false)
	var idle_frame := AtlasTexture.new()
	idle_frame.atlas = texture
	idle_frame.region = Rect2(0, 0, 32, 32)
	sf.add_frame("idle", idle_frame)

	sf.add_animation("open")
	sf.set_animation_loop("open", false)
	sf.set_animation_speed("open", 8.0)
	for i in 4:
		var at := AtlasTexture.new()
		at.atlas = texture
		at.region = Rect2(i * 32, 0, 32, 32)
		sf.add_frame("open", at)

	return sf

func _on_body_entered(body: Node) -> void:
	if opened:
		return
	if body.is_in_group("player"):
		opened = true
		collision.set_deferred("disabled", true)
		anim.play("open")
		audio.play()

func _on_animation_finished() -> void:
	if anim.animation == "open":
		_offer_card_reward()
		queue_free()

func _offer_card_reward() -> void:
	var cards: Array[CardResource] = []

	if bullet_override != BulletOverride.RANDOM:
		cards.append(GlobalData.make_bullet_card(_override_to_type(bullet_override)))
	else:
		var pool: Array = []
		for t in GlobalData.BULLET_CONTENT.keys():
			pool.append({"kind": "bullet", "type": t})
		for card in GlobalData.ability_pool:
			pool.append({"kind": "ability", "card": card})
		pool.shuffle()

		for i in 3:
			var entry = pool[i]
			if entry["kind"] == "bullet":
				cards.append(GlobalData.make_bullet_card(entry["type"]))
			else:
				cards.append(entry["card"])

	var panel: CardRewardPanel = REWARD_PANEL_SCENE.instantiate()
	GlobalData.world.add_child(panel)
	panel.card_chosen.connect(func(card: CardResource):
		if card is BulletCard:
			GlobalData.bullet_deck.draw_pile.append(card)
			GlobalData.bullet_deck.draw_pile.shuffle()
		elif card is AbilityCard:
			GlobalData.card_deck.draw_pile.append(card)
			GlobalData.card_deck.draw_pile.shuffle()
	)
	panel.offer(cards)

func _override_to_type(override: BulletOverride) -> BulletCard.Type:
	match override:
		BulletOverride.BASIC: return BulletCard.Type.BASIC
		BulletOverride.AIR: return BulletCard.Type.AIR
		BulletOverride.POISON: return BulletCard.Type.POISON
		BulletOverride.ELECTRICITY: return BulletCard.Type.ELECTRICITY
		BulletOverride.FIRE: return BulletCard.Type.FIRE
		BulletOverride.ICE: return BulletCard.Type.ICE
	return BulletCard.Type.BASIC
