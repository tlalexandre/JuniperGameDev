extends CharacterBody2D
class_name Enemy

signal died

@export var speed = 250
var player_chase = false
var player

@export var max_health := 5
var current_health := max_health
@onready var health_bar: ProgressBar = $Control/HBoxContainer/HealthBar

@onready var weakness_icon: TextureRect = $Control/HBoxContainer/TextureRect/WeaknessIcon


@onready var attack_cooldown = 1.5
@onready var line_of_sight: RayCast2D = $RayCast2D
# Reference to your AnimatedSprite2D node
@onready var sprite: AnimatedSprite2D = $Sprite 

@export var attack_anim_duration := 0.5 
var can_attack = true
@export var dmg_enemy: float = 1
enum Status { NONE, KNOCKBACK, STUN, SLIDE, DMG_ON_TICK}
var current_status = Status.NONE
var status_timer = 0.0
var status_velocity = Vector2.ZERO
@export var points:int = 100

var is_attacking = false
var is_dead = false
# Flag to lock the enemy movement during the alert phase
var is_alerting = false 
var has_spotted_player = false 

# Control local para cuando recibe daño
var is_taking_damage = false 

# NUEVAS VARIABLES: Para la memoria residual y búsqueda del enemigo
var is_searching = false
var last_seen_direction := Vector2.ZERO

# Poison vars
var poison_stacks := 0
var poison_tick_interval := 1.0
var poison_tick_timer := 0.0
var poison_dmg = 1
var is_on_cooldown = false

const WEAKNESS_ICONS = {
	"rat":    preload("res://Assets/Bullet_Icons/bullet_poison.png"),
	"fish":   preload("res://Assets/Bullet_Icons/bullet_electric.png"),
	"ghost":  preload("res://Assets/Bullet_Icons/bullet_air.png"),
	"candle": preload("res://Assets/Bullet_Icons/bullet_ice.png"),
	"book":   preload("res://Assets/Bullet_Icons/bullet_fire.png"),
}

func _ready() -> void:
	player = GlobalData.player
	health_bar.set_health(current_health, max_health)
	_set_weakness_icon()

func _set_weakness_icon() -> void:
	for group in WEAKNESS_ICONS:
		if is_in_group(group):
			weakness_icon.texture = WEAKNESS_ICONS[group]
			return

func _physics_process(delta):
	if is_dead:
		return
		
	if current_status == Status.DMG_ON_TICK:
		_process_status(delta)
		_process_chase(delta)
	elif current_status != Status.NONE:
		_process_status(delta)
	elif is_attacking or is_alerting or is_taking_damage:
		# Stop moving completely during attack, alert phase or damage stun
		velocity = Vector2.ZERO
	else:
		_process_chase(delta)
		
	_update_animations()
	move_and_slide()
		
func _process_chase(delta: float) -> void:
	if player_chase and is_instance_valid(player):
		line_of_sight.target_position = player.global_position - global_position
		line_of_sight.force_raycast_update()
		
		if line_of_sight.is_colliding() and line_of_sight.get_collider() == player:
			# Si te ve, cancelamos cualquier búsqueda anterior porque ya sabe dónde estás
			is_searching = false
			
			# If the raycast hits the player for the first time, trigger alert
			if not has_spotted_player:
				_trigger_alert()
				return
			
			if not is_alerting:
				# Guardamos la última dirección en la que te vio
				last_seen_direction = (player.position - position).normalized()
				velocity = last_seen_direction * speed
				
				if velocity.x != 0:
					sprite.flip_h = velocity.x < 0
		else:
			# MODIFICADO: Si te pierde de vista (por ejemplo, tras una pared), inicia la búsqueda
			if has_spotted_player and not is_searching:
				_start_searching_phase()
			
			# Si está en modo búsqueda, sigue caminando en la última dirección registrada
			if is_searching:
				velocity = last_seen_direction * speed
				if velocity.x != 0:
					sprite.flip_h = velocity.x < 0
			else:
				velocity = Vector2.ZERO
	else:
		# Si sales del área de detección por completo, también limpiamos variables
		if is_searching:
			velocity = last_seen_direction * speed

		else:
			velocity = Vector2.ZERO
			has_spotted_player = false 

func _start_searching_phase() -> void:
	is_searching = true
	
	# Camina en esa dirección durante 1.5 segundos (puedes cambiar este tiempo a tu gusto)
	await get_tree().create_timer(1.5).timeout
	
	# Si tras ese tiempo sigue sin verte, se rinde y vuelve a Idle
	if is_searching:
		is_searching = false
		has_spotted_player = false
		velocity = Vector2.ZERO

func _update_animations() -> void:
	if is_dead:
		return
		
	# Máxima prioridad para la animación de recibir daño si la flag está activa
	if is_taking_damage:
		if sprite.animation != "DamageTaken":
			sprite.play("DamageTaken")
		return
		
	# 1. Highest Priority: Attack animation
	if is_attacking:
		if sprite.animation != "Attack":
			sprite.play("Attack")
		return
		
	# 2. Second Priority: Alert reaction
	if is_alerting:
		if sprite.animation != "Alert":
			sprite.play("Alert")
		return
		
	# 3. If the enemy is on cooldown right after an attack, freeze it on the first frame of Attack
	#if is_on_cooldown and can_attack:
		#if sprite.animation != "Attack":
			#sprite.animation = "Attack"
		#sprite.frame = 0
		#sprite.stop()
		#return
		
	# 4. Movement and Idle priority (Aquí entra automáticamente la búsqueda porque velocity > 0)
	if velocity.length() > 0:
		sprite.play("Walk")
	else:
		sprite.play("Idle")

func _trigger_alert() -> void:
	has_spotted_player = true
	is_alerting = true
	velocity = Vector2.ZERO
	
	# CHANGED: Wait exactly 0.5 seconds (half a second)
	await get_tree().create_timer(0.5).timeout
	
	is_alerting = false

# Status and damage processing
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
			poison_tick_timer += delta
			if poison_tick_timer >= poison_tick_interval:
				poison_tick_timer = 0.0
				take_damage(poison_dmg * poison_stacks)
				
	if status_timer <= 0.0:
		if current_status == Status.DMG_ON_TICK:
			health_bar.modulate = Color.WHITE
		current_status = Status.NONE
		poison_stacks = 0
		poison_tick_timer = 0.0
		
func apply_status(status: Status, direction: Vector2, force: float, duration: float) -> void:
	if is_dead: return
	if status == Status.DMG_ON_TICK:
		poison_stacks += 1
		status_timer = max(status_timer, duration) if current_status == Status.DMG_ON_TICK else duration
		current_status = Status.DMG_ON_TICK
		health_bar.modulate = Color(0.4, 1.0, 0.4)
	else:
		if current_status == Status.DMG_ON_TICK:
			health_bar.modulate = Color.WHITE
			poison_stacks = 0
			poison_tick_timer = 0.0
		current_status = status
		status_velocity = direction * force
		status_timer = duration

# Detection Areas
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body == GlobalData.player:
		player = GlobalData.player
		player_chase = true

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player:
		# Si sale del área pero está buscando, dejamos que termine de buscar antes de vaciar al player
		if not is_searching:
			player = null
			player_chase = false

func _on_proximity_area_body_entered(body: Node2D) -> void:
	if body == GlobalData.player:
		player = GlobalData.player
		player_chase = false

func _on_proximity_area_body_exited(body: Node2D) -> void:
	if body == GlobalData.player:
		player = GlobalData.player
		player_chase = true

func take_damage(amount: float):
	if is_dead: return
	current_health -= amount
	health_bar.set_health(current_health, max_health)
	if current_health <= 0:
		die()
	else:
		is_taking_damage = true
		is_attacking = false
		
		# Flash white then back to normal
		var tween = create_tween()
		tween.tween_property(sprite, "modulate", Color.WHITE * 3.0, 0.05)
		tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)
		
		await get_tree().create_timer(0.3).timeout
		is_taking_damage = false


func die():
	if is_dead: return
	is_dead = true
	velocity = Vector2.ZERO
	died.emit()
	GlobalData.score += points
	GlobalData.barrel_hud.update_score(GlobalData.score)
	sprite.play("Die")
	await get_tree().create_timer(1.0).timeout 
	queue_free()

func _on_attack_area_body_entered(body: Node2D) -> void:
	if is_dead: return
	if body.is_in_group("player") or body == GlobalData.player:
		can_attack = true
		attack()

func _on_attack_area_body_exited(body: Node2D) -> void:
	if body == player or body.is_in_group("player"):
		can_attack = false
		
func attack() -> void:
	if not can_attack or is_on_cooldown or is_attacking or is_dead or is_taking_damage:
		return

	is_attacking = true

	if player and is_instance_valid(player):
		player.take_damage(dmg_enemy)

	await get_tree().create_timer(attack_anim_duration, false, false, true).timeout

	is_attacking = false
	is_on_cooldown = true

	await get_tree().create_timer(attack_cooldown, false, false, true).timeout
	is_on_cooldown = false

	if can_attack:
		attack()
