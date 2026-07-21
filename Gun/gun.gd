extends AnimatedSprite2D
@onready var marker_2d: Marker2D = $Marker2D
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

var deck: BulletDeck
var barrel_capacity: int = 6
var barrel: Array[BulletCard] = []
var selected_bullet: BulletCard
var _reloading := false
var _spin_connected := false

func _ready() -> void:
	deck = BulletDeck.new()
	deck.draw_pile.append_array(GlobalData.bullet_loadout) # now Array[BulletCard]
	deck.draw_pile.shuffle()
	barrel.assign(deck.draw(barrel_capacity))
	GlobalData.barrel_hud.update_icons_from_chamber(barrel)
	


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


func random_bullet() -> void:
	if barrel.is_empty():
		return
	var idx = randi() % barrel.size()
	selected_bullet = barrel[idx]
	barrel.remove_at(idx)

func _on_spin_complete(_bullet_type) -> void:
	play(get_animation_for_bullet(selected_bullet))
	GlobalData.barrel_hud.update_icons_from_chamber(barrel)


func shoot() -> void:
	if _reloading:
		return
	var hud = GlobalData.barrel_hud
	if not _spin_connected:
		hud.spin_complete.connect(_on_spin_complete)
		_spin_connected = true
	if hud.state == hud.State.IDLE:
		random_bullet()
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
		GlobalData.world.add_child(new_bullet)
		deck.discard([selected_bullet])
		GlobalData.barrel_hud.update_ammo(barrel.size(), barrel_capacity)
		hud.reset()
		play("basic")
		if barrel.is_empty():
			reload()

func reload() -> void:
	_reloading = true
	GlobalData.barrel_hud.play_reload()
	if not barrel.is_empty():
		deck.discard(barrel)
		barrel.clear()
	await get_tree().create_timer(2.0).timeout
	barrel.assign(deck.draw(barrel_capacity))
	GlobalData.barrel_hud.update_icons_from_chamber(barrel)
	_reloading = false


func discard_from_barrel(card: BulletCard) -> void:
	barrel.erase(card)
	deck.discard([card])
	GlobalData.barrel_hud.update_icons_from_chamber(barrel)
	if barrel.is_empty():
		reload()
