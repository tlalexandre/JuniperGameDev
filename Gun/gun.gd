extends Sprite2D

@onready var marker_2d: Marker2D = $Marker2D
const BULLET = preload("uid://dd4n6m088eqd5")
const BULLET_AIR = preload("uid://go2mccs08y7b")
const BULLET_POISON = preload("uid://cmas4n4etfuy2")
const BULLET_ELECTRICITY = preload("uid://cvsap4gf682m3")
var selected_bullet
var BulletTypes : Array = [BULLET, BULLET_AIR, BULLET_POISON, BULLET_ELECTRICITY]  

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	look_at(get_global_mouse_position())

func random_bullet():
	selected_bullet = BulletTypes.pick_random()

func shoot() -> void:
	random_bullet()
	var new_bullet = selected_bullet.instantiate()
	new_bullet.position = marker_2d.global_position
	new_bullet.target_position = (get_global_mouse_position()-marker_2d.global_position).normalized()
	GlobalData.world.add_child(new_bullet)
