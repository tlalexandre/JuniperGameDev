extends CanvasLayer
const CARD_VIEW_SCENE = preload("res://CardView/card_view.tscn")

func _ready() -> void:
	var card_a := BulletCard.new()
	card_a.type = BulletCard.Type.FIRE
	card_a.display_name = "Fire"
	card_a.icon = preload("uid://bi6hppefpstc8")
	card_a.description = "Explodes on impact, damaging nearby enemies. Deals bonus damage to Books."

	var card_b := BulletCard.new()
	card_b.type = BulletCard.Type.ICE
	card_b.display_name = "Ice"
	card_b.icon = preload("uid://plu5rc3iyxji")
	card_b.description = "Bounces off walls up to 3 times. Deals bonus damage to Candles."

	var view_a: CardView = CARD_VIEW_SCENE.instantiate()
	add_child(view_a)
	view_a.position = Vector2(200, 200)
	view_a.display(card_a)

	var view_b: CardView = CARD_VIEW_SCENE.instantiate()
	add_child(view_b)
	view_b.position = Vector2(420, 200)
	view_b.display(card_b)

	print("--- appearing ---")
	view_a.play_appear()
	await get_tree().create_timer(0.4).timeout
	view_b.play_appear()

	await get_tree().create_timer(2.0).timeout
	print("--- disappearing A ---")
	view_a.play_disappear()

	await get_tree().create_timer(1.0).timeout
	print("--- disappearing B ---")
	view_b.play_disappear()
