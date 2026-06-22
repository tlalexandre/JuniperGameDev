extends Control

enum State { IDLE, SPINNING, LOADED }
var state: State = State.IDLE

@onready var barrel_ring: Control = $BarrelRing
@onready var selected_icon: TextureRect = $SelectedBullet/SelectedIcon

var pointer_angle: float = -PI / 2
const ANGLE_STEP = TAU / 6.0
var icon_slots := {}
var icon_angles := {}

signal spin_complete(bullet_type)

func _ready() -> void:
	selected_icon.hide()
	GlobalData.barrel_hud = self
	icon_slots = {
		GlobalData.FIRE : $BarrelRing/Icon_0,
		GlobalData.ELECTRICITY: $BarrelRing/Icon_1,
		GlobalData.ICE : $BarrelRing/Icon_2,
		GlobalData.POISON: $BarrelRing/Icon_3,
		GlobalData.AIR: $BarrelRing/Icon_4,
		GlobalData.BULLET: $BarrelRing/Icon_5,
	}
	icon_angles = {
		$BarrelRing/Icon_0: -PI/2 + 0 * ANGLE_STEP,
		$BarrelRing/Icon_1: -PI/2 + 1 * ANGLE_STEP,
		$BarrelRing/Icon_2: -PI/2 + 2 * ANGLE_STEP,
		$BarrelRing/Icon_3: -PI/2 + 3 * ANGLE_STEP,
		$BarrelRing/Icon_4: -PI/2 + 4 * ANGLE_STEP,
		$BarrelRing/Icon_5: -PI/2 + 5 * ANGLE_STEP,
	}
	
func _process(delta: float) -> void:
	pass

var spin_tween: Tween

func spin_to(chosen_bullet) -> void:
	if state != State.IDLE:
		return
	state = State.SPINNING
	selected_icon.hide()

	var icon_node = icon_slots.get(chosen_bullet)
	var base_angle = icon_angles.get(icon_node)
	var current_rot = barrel_ring.rotation
	var landing_offset = fposmod(pointer_angle - base_angle - current_rot, TAU)
	var target_rot = current_rot + TAU * 2.0 + landing_offset  # 2 full spins then land

	if spin_tween:
		spin_tween.kill()
	spin_tween = create_tween()
	spin_tween.tween_property(barrel_ring, "rotation", target_rot, 1.2)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	spin_tween.tween_callback(func():
		state = State.LOADED
		selected_icon.texture = icon_node.texture
		selected_icon.show()
		spin_complete.emit(chosen_bullet)
	)
	
func reset() -> void:
	if spin_tween:
		spin_tween.kill()
	state = State.IDLE
	selected_icon.hide()
