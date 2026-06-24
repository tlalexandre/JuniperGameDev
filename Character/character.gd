extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var camera: Camera2D = $Camera2D
@onready var hit_audio: AudioStreamPlayer2D = $HitAudio
signal died

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var last_direction = Vector2.DOWN
var max_health := 20
var current_health := 20


func _ready():
	GlobalData.barrel_hud.update_health(current_health,max_health)
	GlobalData.player = self

func _physics_process(delta: float) -> void:

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var horizontal_direction := Input.get_axis("left", "right")
	var vertical_direction := Input.get_axis("up","down")
	if horizontal_direction != 0:
		animated_sprite_2d.flip_h = horizontal_direction < 0
	
	if horizontal_direction:
		velocity.x = horizontal_direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if vertical_direction:
		velocity.y = vertical_direction * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
		
	if velocity != Vector2.ZERO:
		if not audio.playing:
			animated_sprite_2d.play("Walking")
			audio.play()
	else:
		audio.stop()
		animated_sprite_2d.play("Idle")
	#Calculation of last direction to allow have a direction for the dodge
	var input_dir := Vector2(horizontal_direction, vertical_direction)
	
	if input_dir != Vector2.ZERO:
		last_direction = input_dir.normalized()
	if Input.is_action_just_pressed("dodge"):
		var dodge_dir := input_dir
		if input_dir != Vector2.ZERO :
			velocity += dodge_dir * 20 * SPEED
		else :	
			velocity += last_direction * 20 * SPEED
	move_and_slide()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		get_node("Gun").shoot()
		
func take_damage(amount: float):
	animated_sprite_2d.play("DamageTaken")
	hit_audio.stream = preload("uid://uxk2w6hhptc2")
	hit_audio.play()
	current_health -= amount
	GlobalData.barrel_hud.update_health(current_health, max_health)
	shake()
	if current_health <= 0:
		die()

func die():
	set_physics_process(false)
	set_process_input(false)
	animated_sprite_2d.play("Die")
	hit_audio.stream = preload("uid://rburi1ot2d10")
	hit_audio.play()
	await get_tree().create_timer(hit_audio.stream.get_length()).timeout  # wait exact duration
	died.emit()
	queue_free()

func shake(duration: float = 0.2, strength: float = 8.0) -> void:
	var tween = create_tween()
	var elapsed = 0.0
	while elapsed < duration:
		var offset = Vector2(randf_range(-strength, strength), randf_range(-strength, strength))
		tween.tween_property(camera, "offset", offset, 0.05)
		elapsed += 0.05
	tween.tween_property(camera, "offset", Vector2.ZERO, 0.05)
