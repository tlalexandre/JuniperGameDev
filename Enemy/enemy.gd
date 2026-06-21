extends CharacterBody2D

signal died

var speed = 350
var player_chase = false
var player
var current_health := 10
var max_health := 10
@onready var health_bar: ProgressBar = $HealthBar
@onready var attack_cooldown = 1
var can_attack = true
var dmg_enemy = 1
enum Status { NONE, KNOCKBACK, STUN, SLIDE, DMG_ON_TICK}
var current_status = Status.NONE
var status_timer = 0.0
var status_velocity = Vector2.ZERO
var poison_dmg = .05
var is_on_cooldown = false

func _ready() -> void:
	player = GlobalData.player
	health_bar.set_health(current_health, max_health)
	
func _physics_process(delta: float) -> void:
	if current_status != Status.NONE:
		_process_status(delta)
	else:
		if player_chase:
			var direction = (player.position-position).normalized()
			velocity = direction * speed
		else :
			velocity = Vector2.ZERO
	move_and_slide()
	
func _process_status(delta: float) -> void:
	status_timer -= delta
	match current_status:
		Status.KNOCKBACK:
			velocity = status_velocity
			status_velocity = status_velocity.move_toward(Vector2.ZERO, 800 * delta)
		Status.STUN:
			velocity = Vector2.ZERO
		Status.SLIDE:
			velocity = -status_velocity
		Status.DMG_ON_TICK:
			take_damage(poison_dmg)
	if status_timer <= 0.0:
		current_status = Status.NONE
		
func apply_status(status: Status, direction: Vector2, force: float, duration: float) -> void:
	current_status = status
	status_velocity = direction * force
	status_timer = duration

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body == player:
		player_chase = true

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player:
		player_chase = false

func take_damage(amount: float):
	current_health -= amount
	health_bar.set_health(current_health, max_health)
	if current_health <= 0:
		die()

func die():
	died.emit()
	queue_free()
	
	


func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		can_attack = true
		attack()
	

func _on_attack_area_body_exited(body: Node2D) -> void:
		can_attack = false

func attack() -> void:
	if not can_attack or is_on_cooldown:
		return
	if player:
		player.take_damage(dmg_enemy)
	is_on_cooldown = true
	await get_tree().create_timer(attack_cooldown).timeout
	is_on_cooldown = false
	attack()
	
	
	
	
