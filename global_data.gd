extends Node
@onready var world = $"../World"
@onready var player = $"../World/Player"
var barrel_hud
var bullet_deck: BulletDeck
var score: int = 0
var floor_number: int = 1

const BULLET = preload("uid://dd4n6m088eqd5")
const AIR = preload("uid://go2mccs08y7b")
const POISON = preload("uid://cmas4n4etfuy2")
const ELECTRICITY = preload("uid://cvsap4gf682m3")
const FIRE = preload("uid://dbcrp1dn42sqi")
const ICE = preload("uid://34njt7lqxbsb")

func _ready() -> void:
	bullet_deck = BulletDeck.new()
	bullet_deck.draw_pile.append_array(_make_starter_pool())
	bullet_deck.draw_pile.shuffle()

func _make_card(type: BulletCard.Type, scene: PackedScene) -> BulletCard:
	var c = BulletCard.new()
	c.type = type
	c.scene = scene
	return c

func _make_starter_pool() -> Array[BulletCard]:
	var pool: Array[BulletCard] = []
	for i in 50:
		pool.append(_make_card(BulletCard.Type.BASIC, BULLET))
	return pool
