extends Control
enum State { IDLE, SPINNING, LOADED }
var state: State = State.IDLE

@onready var barrel_ring: Control = $BarrelRing
@onready var selected_icon: TextureRect = $SelectedBullet/SelectedIcon
@onready var swap_menu: Panel = $SwapMenu

var pointer_angle: float = -PI / 2
const ANGLE_STEP = TAU / 6.0

var icon_nodes := []   # index → TextureRect node
var icon_angles := {}  # node → angle

signal spin_complete(bullet_type)

# Bullet type → icon texture
var bullet_icon_map := {}

func _ready() -> void:
	selected_icon.hide()
	GlobalData.barrel_hud = self
	

	bullet_icon_map = {
		GlobalData.BULLET:      preload("res://Assets/Bullet_Icons/bullet.png"),
		GlobalData.AIR:         preload("res://Assets/Bullet_Icons/wind.png"),
		GlobalData.POISON:      preload("res://Assets/Bullet_Icons/poison.png"),
		GlobalData.ELECTRICITY: preload("res://Assets/Bullet_Icons/electricity.png"),
		GlobalData.FIRE:        preload("res://Assets/Bullet_Icons/fire.png"),
		GlobalData.ICE:         preload("res://Assets/Bullet_Icons/ice.png"),
	}

	icon_nodes = [
		$BarrelRing/Icon_0,
		$BarrelRing/Icon_1,
		$BarrelRing/Icon_2,
		$BarrelRing/Icon_3,
		$BarrelRing/Icon_4,
		$BarrelRing/Icon_5,
	]

	icon_angles = {
		icon_nodes[0]: -PI/2 + 0 * ANGLE_STEP,
		icon_nodes[1]: -PI/2 + 1 * ANGLE_STEP,
		icon_nodes[2]: -PI/2 + 2 * ANGLE_STEP,
		icon_nodes[3]: -PI/2 + 3 * ANGLE_STEP,
		icon_nodes[4]: -PI/2 + 4 * ANGLE_STEP,
		icon_nodes[5]: -PI/2 + 5 * ANGLE_STEP,
	}
	
	print("bullet_loadout size: ", GlobalData.bullet_loadout.size())
	print("first entry: ", GlobalData.bullet_loadout[0])
	print("icon_map has bullet: ", bullet_icon_map.has(GlobalData.BULLET))
	
	update_icons(GlobalData.bullet_loadout)
	
func update_icons(loadout: Array) -> void:
	for i in 6:
		var tex = bullet_icon_map.get(loadout[i])
		if tex:
			icon_nodes[i].texture = tex

func update_icons_from_chamber(chamber: Array) -> void:
	for i in 6:
		if i < chamber.size():
			var tex = bullet_icon_map.get(chamber[i])
			if tex:
				icon_nodes[i].texture = tex
		else:
			icon_nodes[i].texture = null  # empty slot


func _process(delta: float) -> void:
	pass

var spin_tween: Tween

func spin_to(slot_index: int, bullet_type) -> void:
	if state != State.IDLE:
		return
	state = State.SPINNING
	selected_icon.hide()

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
		selected_icon.texture = icon_node.texture
		selected_icon.show()
		spin_complete.emit(bullet_type)
	)

func reset() -> void:
	if spin_tween:
		spin_tween.kill()
	state = State.IDLE
	selected_icon.hide()

func show_swap_menu(bullet_type) -> void:
	swap_menu.show_for_bullet(bullet_type)
