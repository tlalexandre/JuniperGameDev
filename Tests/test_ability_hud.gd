extends Node

var slots: AbilitySlots
var hud: AbilityHud

func _ready() -> void:
	var cards: Array[AbilityCard] = []
	var defs = [["Dash Blast", 1.0], ["Barrier", 2.0], ["Overcharge", 3.0], ["Time Slip", 1.5]]
	for d in defs:
		var c = AbilityCard.new()
		c.display_name = d[0]
		c.cooldown = d[1]
		cards.append(c)

	slots = AbilitySlots.new()
	add_child(slots)
	slots.setup(cards)

	hud = AbilityHud.new()
	add_child(hud)
	hud.bind(slots)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ability_0"):
		slots.use(0)
	elif event.is_action_pressed("ability_1"):
		slots.use(1)
	elif event.is_action_pressed("ability_2"):
		slots.use(2)
	elif event.is_action_pressed("ability_3"):
		slots.use(3)
