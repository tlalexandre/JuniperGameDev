extends Control

@onready var barrel_ring: Control = $BarrelRing
@onready var selected_icon: TextureRect = $SelectedBullet/SelectedIcon



var spin_speed: float = 6.0
var spinning: bool = true
var pointer_angle : float = -PI /2

var icon_slots := { } 
const ANGLE_STEP = TAU / 6.0  # 60° in radians

var icon_angles := {}  # icon node -> angle (radians, 0 = top, clockwise)

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
	if spinning:
		barrel_ring.rotation += spin_speed * delta

var stop_tween: Tween

func stop_spin(chosen_bullet) -> void:
	spinning = false
	var icon_node = icon_slots.get(chosen_bullet)
	selected_icon.texture = icon_node.texture
	selected_icon.show()

	var base_angle = icon_angles.get(icon_node)
	var current_rot = barrel_ring.rotation 
	var target_rot = current_rot + fposmod(pointer_angle - base_angle - current_rot, TAU) + TAU * 2

	if stop_tween:
		stop_tween.kill()
	stop_tween = create_tween()
	stop_tween.tween_property(barrel_ring, "rotation", target_rot, 1.0)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func resume_spin() -> void:
	if stop_tween:
		stop_tween.kill()
	spinning = true
	selected_icon.hide()
