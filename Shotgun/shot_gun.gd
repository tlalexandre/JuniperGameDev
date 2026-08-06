extends AnimatedSprite2D
@onready var marker_2d: Marker2D = $Marker2D
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var bullet_barrel: BulletBarrel = $BulletBarrel

const CONE_SPREAD_DEGREES: float = 30.0

func _ready() -> void:
	bullet_barrel.barrel_changed.connect(_on_barrel_changed)
	bullet_barrel.setup(GlobalData.bullet_deck)

func _on_barrel_changed(barrel: Array, capacity: int) -> void:
	if not GlobalData.barrel_hud:
		return
	GlobalData.barrel_hud.update_icons_from_chamber(barrel,capacity)
	GlobalData.barrel_hud.update_ammo(barrel.size(), capacity)

func _process(delta: float) -> void:
	look_at(get_global_mouse_position())
	flip_v = get_global_mouse_position().x < global_position.x

func shoot() -> void:
	if bullet_barrel.reloading:
		return
	var cards = bullet_barrel.take_all()
	if cards.is_empty():
		return

	audio.stream = preload("uid://c2sx8yu45j3lp")
	audio.play()
	play("fire")

	var base_dir = (get_global_mouse_position() - marker_2d.global_position).normalized()
	var base_angle = base_dir.angle()
	var count = cards.size()
	var start_angle = base_angle - deg_to_rad(CONE_SPREAD_DEGREES) / 2.0
	var step = deg_to_rad(CONE_SPREAD_DEGREES) / max(count - 1, 1)

	for i in count:
		var card = cards[i]
		var angle = base_angle if count == 1 else start_angle + step * i
		var dir = Vector2.RIGHT.rotated(angle)
		var new_bullet = card.scene.instantiate()
		new_bullet.position = marker_2d.global_position
		new_bullet.target_position = dir
		GlobalData.world.add_child(new_bullet)
		bullet_barrel.fire(card)

	
