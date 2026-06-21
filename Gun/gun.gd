extends Sprite2D

@onready var marker_2d: Marker2D = $Marker2D
const BULLET = preload("uid://dd4n6m088eqd5")
const AIR = preload("uid://go2mccs08y7b")
const POISON = preload("uid://cmas4n4etfuy2")
const ELECTRICITY = preload("uid://cvsap4gf682m3")
var selected_bullet
var BulletTypes : Array = [GlobalData.BULLET, GlobalData.AIR, GlobalData.POISON, GlobalData.ELECTRICITY, GlobalData.FIRE, GlobalData.ICE]
var bullet_ready = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	look_at(get_global_mouse_position())

func random_bullet():
	selected_bullet = BulletTypes.pick_random()

func shoot() -> void:
	if not bullet_ready:
		random_bullet()
		bullet_ready = true
		GlobalData.barrel_hud.stop_spin(selected_bullet)
		return
	var new_bullet = selected_bullet.instantiate()
	new_bullet.position = marker_2d.global_position
	new_bullet.target_position = (get_global_mouse_position()-marker_2d.global_position).normalized()
	GlobalData.world.add_child(new_bullet)
	bullet_ready = false
	GlobalData.barrel_hud.resume_spin()
