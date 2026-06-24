class_name Bullet
extends CharacterBody2D

@export var speed: int = 400
@export var despawn_time = 1
@export var bullet_dmg = 1
@export var bullet_color: Color = Color.WHITE  

var target_position
var _trail: CPUParticles2D

func _ready() -> void:
	rotation = target_position.angle() + deg_to_rad(90)
	_setup_trail()
	despawn()

func _setup_trail() -> void:
	_trail = CPUParticles2D.new()
	add_child(_trail)
	_trail.position = Vector2(0, 20)  # push spawn point down, tweak the value to taste
	_trail.emitting = true
	_trail.amount = 16
	_trail.lifetime = 0.2
	_trail.explosiveness = 0.0       # continuous stream
	_trail.spread = 10.0
	_trail.direction = Vector2(0, 1) # behind the bullet (local space, bullet faces up)
	_trail.initial_velocity_min = 20.0
	_trail.initial_velocity_max = 40.0
	_trail.scale_amount_min = 2.0
	_trail.scale_amount_max = 4.0
	_trail.color = bullet_color
	_trail.gravity = Vector2(0,0)

func _physics_process(delta: float) -> void:
	velocity = target_position * speed
	move_and_slide()

func despawn() -> void:
	await get_tree().create_timer(despawn_time).timeout
	queue_free()

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		body.take_damage(bullet_dmg)
	queue_free()
