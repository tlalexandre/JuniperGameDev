extends CanvasLayer

const CARD_VIEW_SCENE = preload("res://CardView/card_view.tscn")

func _ready() -> void:
	var card_a := AbilityCard.new()
	card_a.display_name = "Dash Blast"
	card_a.description = "Effect not yet designed."
	card_a.mana_cost = 2.0

	var card_b := AbilityCard.new()
	card_b.display_name = "Overcharge"
	card_b.description = "A powerful, costly burst. Effect not yet designed."
	card_b.mana_cost = 4.0

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
