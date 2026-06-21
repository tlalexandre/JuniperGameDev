extends CharacterBody2D
class_name Enemy

signal died

var speed = 250
var player_chase = false
var player
var current_health := 10
var max_health := 10

@onready var health_bar: ProgressBar = $HealthBar
@onready var attack_cooldown = 1.5
@onready var line_of_sight: RayCast2D = $RayCast2D
# Reference to your AnimatedSprite2D node
@onready var sprite: AnimatedSprite2D = $Sprite 

var can_attack = true
var dmg_enemy = 1
enum Status { NONE, KNOCKBACK, STUN, SLIDE, DMG_ON_TICK}
var current_status = Status.NONE
var status_timer = 0.0
var status_velocity = Vector2.ZERO

var is_attacking = false
var is_dead = false
# Flag to lock the enemy movement during the alert phase
var is_alerting = false 
var has_spotted_player = false 

# Poison vars
var poison_stacks := 0
var poison_tick_interval := 1.0
var poison_tick_timer := 0.0
var poison_dmg = 1
var is_on_cooldown = false

func _ready() -> void:
	player = GlobalData.player
	health_bar.set_health(current_health, max_health)

func _physics_process(delta):
	if is_dead:
		return
		
	if current_status == Status.DMG_ON_TICK:
		_process_status(delta)
		_process_chase(delta)
	elif current_status != Status.NONE:
		_process_status(delta)
	elif is_attacking or is_alerting:
		# Stop moving completely during attack or alert phase
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
			# If the raycast hits the player for the first time, trigger alert
			if not has_spotted_player:
				_trigger_alert()
				return
			
			if not is_alerting:
				var direction = (player.position - position).normalized()
				velocity = direction * speed
				
				if velocity.x != 0:
					sprite.flip_h = velocity.x < 0
		else:
			velocity = Vector2.ZERO
	else:
		velocity = Vector2.ZERO
		has_spotted_player = false 

func _update_animations() -> void:
	if is_dead:
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
	if is_on_cooldown and can_attack:
		sprite.animation = "Attack"
		return
		
	# 4. Movement and Idle priority
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

func die():
	if is_dead: return
	is_dead = true
	velocity = Vector2.ZERO
	died.emit()
	
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
	if not can_attack or is_on_cooldown or is_attacking or is_dead:
		return
		
	# Start attack state immediately
	is_attacking = true
	
	# CHANGED: Apply damage INSTANTLY when entering range instead of waiting
	if player and is_instance_valid(player):
		player.take_damage(dmg_enemy)
		
	# Wait for the 2 frames of your attack animation to display (e.g., 0.3 seconds)
	await get_tree().create_timer(0.3).timeout
	
	# End attack lock
	is_attacking = false
	is_on_cooldown = true
	
	# Wait for the cooldown period before next strike
	await get_tree().create_timer(attack_cooldown).timeout
	is_on_cooldown = false
	
	if can_attack:
		attack()
