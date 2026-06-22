extends AnimatedSprite2D

@onready var marker_2d: Marker2D = $Marker2D
const BULLET = preload("uid://dd4n6m088eqd5")
const AIR = preload("uid://go2mccs08y7b")
const POISON = preload("uid://cmas4n4etfuy2")
const ELECTRICITY = preload("uid://cvsap4gf682m3")
var selected_bullet
var BulletTypes : Array = [GlobalData.BULLET, GlobalData.AIR, GlobalData.POISON, GlobalData.ELECTRICITY, GlobalData.FIRE, GlobalData.ICE]
var bullet_ready = false
var _spin_connected := false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	look_at(get_global_mouse_position())
	flip_v = get_global_mouse_position().x < global_position.x

func get_animation_for_bullet(bullet) -> String:
	if bullet == GlobalData.AIR: return "air"
	if bullet == GlobalData.POISON: return "poison"
	if bullet == GlobalData.ELECTRICITY: return "electricity"
	if bullet == GlobalData.FIRE: return "fire"
	if bullet == GlobalData.ICE: return "ice"
	return "basic"


func random_bullet():
	selected_bullet = BulletTypes.pick_random()

func _on_spin_complete(bullet_type) -> void:
	play(get_animation_for_bullet(selected_bullet))

func shoot() -> void:
	var hud = GlobalData.barrel_hud
	if not _spin_connected:
		hud.spin_complete.connect(_on_spin_complete)
		_spin_connected = true
	if hud.state == hud.State.IDLE:
		random_bullet()
		hud.spin_to(selected_bullet)
		#play(get_animation_for_bullet(selected_bullet))  # ADD THIS
		return
	if hud.state == hud.State.LOADED:
		var new_bullet = selected_bullet.instantiate()
		new_bullet.position = marker_2d.global_position
		new_bullet.target_position = (get_global_mouse_position() - marker_2d.global_position).normalized()
		GlobalData.world.add_child(new_bullet)
		hud.reset()
		play("basic")  # ADD THIS — reset after firing
