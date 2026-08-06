extends Node

const REWARD_PANEL_SCENE = preload("res://UI/TakeSkipRewardPanel/CardRewardPanel.tscn")

func _ready() -> void:
	var card_a := BulletCard.new()
	card_a.display_name = "Fire"
	card_a.icon = preload("uid://bi6hppefpstc8")
	card_a.description = "Explodes on impact, damaging nearby enemies. Deals bonus damage to Books."

	var card_b := BulletCard.new()
	card_b.display_name = "Ice"
	card_b.icon = preload("uid://plu5rc3iyxji")
	card_b.description = "Bounces off walls up to 3 times. Deals bonus damage to Candles."

	var card_c := BulletCard.new()
	card_c.display_name = "Poison"
	card_c.icon = preload("uid://dy06j721w36cc")
	card_c.description = "Applies damage over time. Deals bonus damage to Rats."

	var panel: CardRewardPanel = REWARD_PANEL_SCENE.instantiate()
	add_child(panel)
	panel.card_chosen.connect(func(card): print("CHOSEN: ", card.display_name))
	panel.reward_skipped.connect(func(): print("SKIPPED"))

	print("--- offering 3 cards ---")
	panel.offer([card_a, card_b, card_c])
