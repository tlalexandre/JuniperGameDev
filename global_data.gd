extends Node

@onready var world = $"../World"
@onready var player = $"../World/Player"
var barrel_hud

const BULLET = preload("uid://dd4n6m088eqd5")
const AIR = preload("uid://go2mccs08y7b")
const POISON = preload("uid://cmas4n4etfuy2")
const ELECTRICITY = preload("uid://cvsap4gf682m3")
const FIRE = preload("uid://dbcrp1dn42sqi")
const ICE = preload("uid://34njt7lqxbsb")
