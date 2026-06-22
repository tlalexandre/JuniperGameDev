extends AnimatedSprite2D

@onready var marker_2d: Marker2D = $Marker2D
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
var selected_bullet
var selected_index: int = 0  
var BulletTypes : Array = [GlobalData.BULLET, GlobalData.BULLET, GlobalData.BULLET,GlobalData.BULLET, GlobalData.BULLET, GlobalData.BULLET]
var bullet_ready = false
var _spin_connected := false
# Called when the node enters the scene tree for the first time.
var loadout : Array = []
var _reloading = false

func _ready() -> void:
	loadout = GlobalData.bullet_loadout.duplicate()
	BulletTypes = loadout.duplicate()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	look_at(get_global_mouse_position())
	flip_v = get_global_mouse_position().x < global_position.x
	if Input.is_action_just_pressed("discard"):
		discard_bullet()
	
func get_animation_for_bullet(bullet) -> String:
	if bullet == GlobalData.AIR: return "air"
	if bullet == GlobalData.POISON: return "poison"
	if bullet == GlobalData.ELECTRICITY: return "electricity"
	if bullet == GlobalData.FIRE: return "fire"
	if bullet == GlobalData.ICE: return "ice"
	return "basic"


func random_bullet():
	selected_index = randi() % BulletTypes.size()
	selected_bullet = BulletTypes[selected_index]

func _on_spin_complete(bullet_type) -> void:
	play(get_animation_for_bullet(selected_bullet))
	BulletTypes.remove_at(selected_index)
	if BulletTypes.is_empty():
		_reloading = true
		GlobalData.barrel_hud.play_reload()
		await get_tree().create_timer(2.0).timeout
		BulletTypes = loadout.duplicate()
		_reloading = false
	GlobalData.barrel_hud.update_icons_from_chamber(BulletTypes)
	
func shoot() -> void:
	if _reloading:
		return
	var hud = GlobalData.barrel_hud
	if not _spin_connected:
		hud.spin_complete.connect(_on_spin_complete)
		_spin_connected = true
	if hud.state == hud.State.IDLE:
		random_bullet()
		hud.spin_to(selected_index, selected_bullet)
		audio.stream = preload("uid://dv1kkfqyjey5r")
		audio.play()
		play(get_animation_for_bullet(selected_bullet))  # ADD THIS
		return
	if hud.state == hud.State.LOADED:
		audio.stream = preload("uid://c2sx8yu45j3lp")
		audio.play()
		var new_bullet = selected_bullet.instantiate()
		new_bullet.position = marker_2d.global_position
		new_bullet.target_position = (get_global_mouse_position() - marker_2d.global_position).normalized()
		GlobalData.world.add_child(new_bullet)
		hud.reset()
		play("basic")  # ADD THIS — reset after firing


func discard_bullet() -> void:
	var hud = GlobalData.barrel_hud
	if _reloading:
		return
	if hud.state != hud.State.LOADED:
		return
	
	# No removal here — bullet was already removed on draw
	
	hud.reset()
	await get_tree().process_frame
	
	random_bullet()
	hud.spin_to(selected_index, selected_bullet)
	audio.stream = preload("uid://dv1kkfqyjey5r")
	audio.play()
	play(get_animation_for_bullet(selected_bullet))
