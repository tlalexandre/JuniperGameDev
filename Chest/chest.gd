extends StaticBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var area: Area2D = $Area2D
const CHEST = preload("uid://dw06pllyddjp6")
const BULLET_PICKUP = preload("uid://63m54ntd0dxo")

var opened := false

func _ready() -> void:
	anim.sprite_frames = _build_frames()
	anim.play("idle")
	area.body_entered.connect(_on_body_entered)
	anim.animation_finished.connect(_on_animation_finished)

func _build_frames() -> SpriteFrames:
	var sf := SpriteFrames.new()
	var texture := CHEST
	
	sf.add_animation("idle")
	sf.set_animation_loop("idle", false)
	var idle_frame := AtlasTexture.new()
	idle_frame.atlas = texture
	idle_frame.region = Rect2(0, 0, 32, 32)
	sf.add_frame("idle", idle_frame)
	
	sf.add_animation("open")
	sf.set_animation_loop("open", false)
	sf.set_animation_speed("open", 8.0)
	for i in 4:
		var at := AtlasTexture.new()
		at.atlas = texture
		at.region = Rect2(i * 32, 0, 32, 32)
		sf.add_frame("open", at)
	
	return sf

func _on_body_entered(body: Node) -> void:
	if opened:
		return
	if body.is_in_group("player"):
		opened = true
		collision.set_deferred("disabled", true)
		anim.play("open")

func _on_animation_finished() -> void:
	if anim.animation == "open":
		_drop_bullet()
		queue_free()

func _drop_bullet() -> void:
	var pool = [
		GlobalData.BULLET,
		GlobalData.AIR,
		GlobalData.POISON,
		GlobalData.ELECTRICITY,
		GlobalData.FIRE,
		GlobalData.ICE,
	]
	var bullet_type = pool.pick_random()
	var pickup = BULLET_PICKUP.instantiate()
	pickup.position = global_position
	GlobalData.world.add_child(pickup)
	pickup.setup(bullet_type)
