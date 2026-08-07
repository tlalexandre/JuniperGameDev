extends AnimatedSprite2D
@onready var marker_2d: Marker2D = $Marker2D
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var bullet_barrel: BulletBarrel = $BulletBarrel

var selected_bullet: BulletCard
var _spin_connected := false

func _ready() -> void:
	bullet_barrel.barrel_changed.connect(_on_barrel_changed)
	bullet_barrel.setup(GlobalData.bullet_deck)
	GlobalData.active_barrel = bullet_barrel
	
func _on_barrel_changed(barrel: Array, capacity: int) -> void:
	GlobalData.barrel_hud.update_icons_from_chamber(barrel, capacity)
	GlobalData.barrel_hud.update_ammo(barrel.size(), capacity)

func _process(delta: float) -> void:
	look_at(get_global_mouse_position())
	flip_v = get_global_mouse_position().x < global_position.x

func get_animation_for_bullet(card: BulletCard) -> String:
	match card.type:
		BulletCard.Type.AIR: return "air"
		BulletCard.Type.POISON: return "poison"
		BulletCard.Type.ELECTRICITY: return "electricity"
		BulletCard.Type.FIRE: return "fire"
		BulletCard.Type.ICE: return "ice"
		_: return "basic"

func shoot() -> void:
	if bullet_barrel.reloading:
		return
	var hud = GlobalData.barrel_hud
	if not _spin_connected:
		hud.spin_complete.connect(_on_spin_complete)
		_spin_connected = true
	if hud.state == hud.State.IDLE:
		selected_bullet = bullet_barrel.take_random()
		if selected_bullet == null:
			return
		hud.spin_to(0, selected_bullet)
		audio.stream = preload("uid://dv1kkfqyjey5r")
		audio.play()
		play(get_animation_for_bullet(selected_bullet))
		return
	if hud.state == hud.State.LOADED:
		audio.stream = preload("uid://c2sx8yu45j3lp")
		audio.play()
		var new_bullet = selected_bullet.scene.instantiate()
		new_bullet.position = marker_2d.global_position
		new_bullet.target_position = (get_global_mouse_position() - marker_2d.global_position).normalized()
		GlobalData.apply_shot_modifiers(new_bullet)
		GlobalData.world.add_child(new_bullet)
		bullet_barrel.fire(selected_bullet)
		GlobalData.consume_shot_modifiers()
		hud.reset()
		play("basic")

func _on_spin_complete(_bullet_type) -> void:
	play(get_animation_for_bullet(selected_bullet))
