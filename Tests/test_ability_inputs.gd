extends Node

@onready var slots := AbilitySlots.new()

func _ready() -> void:
	var cards: Array[AbilityCard] = []
	for i in 4:
		var c = AbilityCard.new()
		c.display_name = "Ability %d" % i
		c.cooldown = 2.0
		cards.append(c)
	add_child(slots)
	slots.setup(cards)
	slots.slot_used.connect(func(i, card): print("Fired via input -> slot ", i, ": ", card.display_name))
	print("Press Q / E / C / V (or controller face buttons) to test. Waiting 5s...")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ability_0"):
		slots.use(0)
	elif event.is_action_pressed("ability_1"):
		slots.use(1)
	elif event.is_action_pressed("ability_2"):
		slots.use(2)
	elif event.is_action_pressed("ability_3"):
		slots.use(3)
