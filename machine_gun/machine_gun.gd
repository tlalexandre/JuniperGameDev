extends AnimatedSprite2D
@onready var marker_2d: Marker2D = $Marker2D
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var bullet_barrel: BulletBarrel = $BulletBarrel
@onready var windup_timer: Timer = $WindupTimer
@onready var fire_timer: Timer = $FireTimer

enum State { IDLE, WINDUP, FIRING }
var state: State = State.IDLE

func _ready() -> void:
	bullet_barrel.barrel_changed.connect(_on_barrel_changed)
	bullet_barrel.setup(GlobalData.bullet_loadout)

	windup_timer.wait_time = 0.5
	windup_timer.one_shot = true
	windup_timer.timeout.connect(_on_windup_complete)

	fire_timer.wait_time = 1.0 / 10.0 # 10 shots/sec
	fire_timer.timeout.connect(_on_fire_tick)

func _on_barrel_changed(barrel: Array) -> void:
	GlobalData.barrel_hud.update_icons_from_chamber(barrel)

func _process(delta: float) -> void:
	look_at(get_global_mouse_position())
	flip_v = get_global_mouse_position().x < global_position.x

func shoot() -> void:
	if state != State.IDLE:
		return
	state = State.WINDUP
	windup_timer.start()

func stop_shooting() -> void:
	if state == State.WINDUP:
		windup_timer.stop()
		state = State.IDLE
	elif state == State.FIRING:
		fire_timer.stop()
		state = State.IDLE

func _on_windup_complete() -> void:
	state = State.FIRING
	fire_timer.start()
	_on_fire_tick()

func _on_fire_tick() -> void:
	if bullet_barrel.reloading:
		return
	var card = bullet_barrel.take_random()
	if card == null:
		return

	audio.stream = preload("uid://c2sx8yu45j3lp")
	audio.play()
	play(get_animation_for_bullet(card))

	var dir = (get_global_mouse_position() - marker_2d.global_position).normalized()
	var new_bullet = card.scene.instantiate()
	new_bullet.position = marker_2d.global_position
	new_bullet.target_position = dir
	GlobalData.world.add_child(new_bullet)

	bullet_barrel.fire(card)
	GlobalData.barrel_hud.update_ammo(bullet_barrel.barrel.size(), bullet_barrel.barrel_capacity)

func get_animation_for_bullet(card: BulletCard) -> String:
	match card.type:
		BulletCard.Type.AIR: return "air"
		BulletCard.Type.POISON: return "poison"
		BulletCard.Type.ELECTRICITY: return "electricity"
		BulletCard.Type.FIRE: return "fire"
		BulletCard.Type.ICE: return "ice"
		_: return "basic"
