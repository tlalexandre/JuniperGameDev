extends Control
enum State { IDLE, SPINNING, LOADED }
var state: State = State.IDLE

@onready var barrel_ring: Control = $HUDPanel/HUDContent/BarrelRing
@onready var bullet_name: Label = $HUDPanel/HUDContent/BulletRow/BulletName
@onready var bullet_icon: TextureRect = $HUDPanel/HUDContent/BulletRow/BulletIcon
@onready var health_bar: ProgressBar = $HUDPanel/HUDContent/HealthRow/HealthBar
@onready var hp_label: Label = $HUDPanel/HUDContent/HealthRow/HPLabel
@onready var score_value: Label = $HUDPanel/HUDContent/StatsRow/ScoreCard/ScoreValue
@onready var floor_value: Label = $HUDPanel/HUDContent/StatsRow/FloorCard/FloorValue
@onready var ammo_value: Label = $HUDPanel/HUDContent/StatsRow/AmmoCard/AmmoValue

@onready var swap_menu = $HUDPanel/SwapContent
@onready var audio: AudioStreamPlayer2D = $"../AudioStreamPlayer2D"

var pointer_angle: float = -PI / 2
const ANGLE_STEP = TAU / 6.0

var icon_nodes := []
var icon_angles := {}
var spin_tween: Tween
signal spin_complete(bullet_type)
signal reload_complete

var bullet_icon_map := {}
var bullet_color_map := {}
var bullet_name_map := {}

func _ready() -> void:
	GlobalData.barrel_hud = self

	bullet_color_map = {
		BulletCard.Type.BASIC:       Color(0.85, 0.85, 0.85),
		BulletCard.Type.AIR:         Color(0.66, 0.90, 0.64),
		BulletCard.Type.POISON:      Color(0.49, 0.81, 0.35),
		BulletCard.Type.ELECTRICITY: Color(0.96, 0.85, 0.38),
		BulletCard.Type.FIRE:        Color(0.88, 0.33, 0.33),
		BulletCard.Type.ICE:         Color(0.39, 0.70, 0.96),
	}

	bullet_name_map = {
		BulletCard.Type.BASIC:       "Basic",
		BulletCard.Type.AIR:         "Air",
		BulletCard.Type.POISON:      "Poison",
		BulletCard.Type.ELECTRICITY: "Electric",
		BulletCard.Type.FIRE:        "Fire",
		BulletCard.Type.ICE:         "Ice",
	}

	bullet_icon_map = {
		BulletCard.Type.BASIC:       preload("uid://dxi38lk2qotpp"),
		BulletCard.Type.AIR:         preload("uid://dk4ijlokb5at8"),
		BulletCard.Type.POISON:      preload("uid://dy06j721w36cc"),
		BulletCard.Type.ELECTRICITY: preload("uid://hituocfik6r2"),
		BulletCard.Type.FIRE:        preload("uid://bi6hppefpstc8"),
		BulletCard.Type.ICE:         preload("uid://plu5rc3iyxji"),
	}

	icon_nodes = [
		$HUDPanel/HUDContent/BarrelRing/Icon_0,
		$HUDPanel/HUDContent/BarrelRing/Icon_1,
		$HUDPanel/HUDContent/BarrelRing/Icon_2,
		$HUDPanel/HUDContent/BarrelRing/Icon_3,
		$HUDPanel/HUDContent/BarrelRing/Icon_4,
		$HUDPanel/HUDContent/BarrelRing/Icon_5
	]

	icon_angles = {
		icon_nodes[0]: -PI/2 + 0 * ANGLE_STEP,
		icon_nodes[1]: -PI/2 + 1 * ANGLE_STEP,
		icon_nodes[2]: -PI/2 + 2 * ANGLE_STEP,
		icon_nodes[3]: -PI/2 + 3 * ANGLE_STEP,
		icon_nodes[4]: -PI/2 + 4 * ANGLE_STEP,
		icon_nodes[5]: -PI/2 + 5 * ANGLE_STEP,
	}

	update_icons_from_chamber([],0) # cleared until a gun's barrel_changed fires
	update_health(20, 20)
	update_score(GlobalData.score)
	update_floor(GlobalData.floor_number)
	update_ammo(0, 0) # will be set correctly once a gun reports in
	await get_tree().process_frame
	barrel_ring.pivot_offset = barrel_ring.size / 2.0

func _process(delta: float) -> void:
	pass

func update_icons_from_chamber(chamber: Array, capacity: int) -> void:
	if capacity > 6:
		barrel_ring.visible = false
		return
	barrel_ring.visible = true
	for i in 6:
		if i < chamber.size():
			var card: BulletCard = chamber[i]
			var tex = bullet_icon_map.get(card.type)
			if tex:
				icon_nodes[i].texture = tex
		else:
			icon_nodes[i].texture = null

func play_reload() -> void:
	audio.stream = preload("uid://b748kn0weghqb")
	audio.play()
	await audio.finished
	reload_complete.emit()

func spin_to(slot_index: int, bullet_card: BulletCard) -> void:
	if state != State.IDLE:
		return
	state = State.SPINNING

	var icon_node = icon_nodes[slot_index]
	var base_angle = icon_angles.get(icon_node)
	var current_rot = barrel_ring.rotation
	var landing_offset = fposmod(pointer_angle - base_angle - current_rot, TAU)
	var target_rot = current_rot + TAU * 2.0 + landing_offset

	if spin_tween:
		spin_tween.kill()
	spin_tween = create_tween()
	spin_tween.tween_property(barrel_ring, "rotation", target_rot, 1.2)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	spin_tween.tween_callback(func():
		state = State.LOADED
		bullet_icon.texture = bullet_icon_map.get(bullet_card.type)
		bullet_name.text = bullet_name_map.get(bullet_card.type, "???")
		spin_complete.emit(bullet_card)
	)

func reset() -> void:
	if spin_tween:
		spin_tween.kill()
	state = State.IDLE
	bullet_name.text = ""

func show_swap_menu(bullet_card: BulletCard) -> void:
	swap_menu.show_for_bullet(bullet_card)

func update_health(current: float, max_health: float) -> void:
	health_bar.max_value = max_health
	health_bar.value = current
	hp_label.text = "%d / %d" % [current, max_health]

func update_score(value: int) -> void:
	score_value.text = str(value)

func update_floor(value: int) -> void:
	floor_value.text = str(value)

func update_ammo(current: int, total: int) -> void:
	ammo_value.text = "%d / %d" % [current, total]
