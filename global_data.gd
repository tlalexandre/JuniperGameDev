extends Node
@onready var world = $"../World"
@onready var player = $"../World/Player"
var barrel_hud
var active_barrel: BulletBarrel
var bullet_deck: BulletDeck
var card_deck: CardDeck
var score: int = 0
var floor_number: int = 1
var ability_hud: AbilityHud
var mana_bar: ManaBar
var player_mana: PlayerMana

var pending_shot_modifiers: Array[Callable] = []

const BULLET = preload("uid://dd4n6m088eqd5")
const AIR = preload("uid://go2mccs08y7b")
const POISON = preload("uid://cmas4n4etfuy2")
const ELECTRICITY = preload("uid://cvsap4gf682m3")
const FIRE = preload("uid://dbcrp1dn42sqi")
const ICE = preload("uid://34njt7lqxbsb")

const ABILITY_DEFINITIONS_PATH := "res://AbilityCard/definitions/"
var ability_pool: Array[AbilityCard] = []

const BULLET_CONTENT := {
	BulletCard.Type.BASIC: {
		"name": "Basic", "scene_key": "BULLET",
		"icon_uid": "uid://dxi38lk2qotpp",
		"desc": "A standard bullet with no special effect."
	},
	BulletCard.Type.AIR: {
		"name": "Air", "scene_key": "AIR",
		"icon_uid": "uid://dk4ijlokb5at8",
		"desc": "Knocks enemies back on hit. Deals bonus damage to Ghosts."
	},
	BulletCard.Type.POISON: {
		"name": "Poison", "scene_key": "POISON",
		"icon_uid": "uid://dy06j721w36cc",
		"desc": "Applies damage over time. Deals bonus damage to Rats."
	},
	BulletCard.Type.ELECTRICITY: {
		"name": "Electric", "scene_key": "ELECTRICITY",
		"icon_uid": "uid://hituocfik6r2",
		"desc": "Stuns the target briefly. Deals bonus damage to Fish."
	},
	BulletCard.Type.FIRE: {
		"name": "Fire", "scene_key": "FIRE",
		"icon_uid": "uid://bi6hppefpstc8",
		"desc": "Explodes on impact, damaging nearby enemies. Deals bonus damage to Books."
	},
	BulletCard.Type.ICE: {
		"name": "Ice", "scene_key": "ICE",
		"icon_uid": "uid://plu5rc3iyxji",
		"desc": "Bounces off walls up to 3 times. Deals bonus damage to Candles."
	},
}

func make_bullet_card(type: BulletCard.Type) -> BulletCard:
	var content: Dictionary = BULLET_CONTENT[type]
	var c := BulletCard.new()
	c.type = type
	c.scene = get(content["scene_key"])
	c.display_name = content["name"]
	c.icon = load(content["icon_uid"])
	c.description = content["desc"]
	return c

func _load_ability_pool() -> Array[AbilityCard]:
	var pool: Array[AbilityCard] = []
	var dir := DirAccess.open(ABILITY_DEFINITIONS_PATH)
	if dir == null:
		push_error("Could not open ability definitions folder: " + ABILITY_DEFINITIONS_PATH)
		return pool
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			var res := load(ABILITY_DEFINITIONS_PATH + file_name)
			if res is AbilityCard:
				pool.append(res)
		file_name = dir.get_next()
	dir.list_dir_end()
	return pool
	
func _ready() -> void:
	ability_pool = _load_ability_pool()

	bullet_deck = BulletDeck.new()
	for i in 12:
		bullet_deck.draw_pile.append(make_bullet_card(BulletCard.Type.BASIC))
	bullet_deck.draw_pile.shuffle()

	var starter_abilities: Array[AbilityCard] = ability_pool.filter(func(c): return c.is_starter)
	card_deck = CardDeck.new()
	card_deck.draw_pile.append_array(starter_abilities.duplicate())
	card_deck.draw_pile.shuffle()

	player_mana = PlayerMana.new()
	add_child(player_mana)

func queue_shot_modifier(modifier: Callable) -> void:
	pending_shot_modifiers.append(modifier)

func apply_shot_modifiers(bullet: Node) -> void:
	for modifier in pending_shot_modifiers:
		modifier.call(bullet)

func consume_shot_modifiers() -> void:
	pending_shot_modifiers.clear()
