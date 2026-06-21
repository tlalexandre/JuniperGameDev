extends CharacterBody2D
class_name Enemy

signal died

var speed = 250
var player_chase = false
var player
var current_health := 10
var max_health := 10
@onready var health_bar: ProgressBar = $HealthBar
@onready var attack_cooldown = 1
@onready var line_of_sight:RayCast2D = $RayCast2D
var can_attack = true
var dmg_enemy = 1
enum Status { NONE, KNOCKBACK, STUN, SLIDE, DMG_ON_TICK}
var current_status = Status.NONE
var status_timer = 0.0
var status_velocity = Vector2.ZERO

#Poison vars
var poison_stacks :=0
var poison_tick_interval := 1.0
var poison_tick_timer :=0.0
var poison_dmg = 1

var is_on_cooldown = false

func _ready() -> void:
	player = GlobalData.player
	health_bar.set_health(current_health, max_health)
	
	
	
func _physics_process(delta):
	if current_status == Status.DMG_ON_TICK:
		_process_status(delta)
		_process_chase(delta)
	elif current_status !=Status.NONE:
		_process_status(delta)
	else:
		_process_chase(delta)
	move_and_slide()
		
func _process_chase(delta:float) -> void:
		# Check if the player is inside the detection area and exists
		if player_chase and is_instance_valid(player):
			# 1. Point the RayCast towards the player
			# target_position is relative to the RayCast's position
			line_of_sight.target_position = player.global_position - global_position
			
			# 2. Force the RayCast to update its collision immediately
			line_of_sight.force_raycast_update()
			
			# 3. Check what the RayCast is colliding with
			if line_of_sight.is_colliding():
				var collider = line_of_sight.get_collider()
				
				# If the first thing the ray hits is the player, chase them
				if collider == player:
					var direction = (player.position - position).normalized()
					velocity = direction * speed
				else:
					# There is a wall or something else blocking the view
					velocity = Vector2.ZERO
			else:
				# If it collides with nothing (but player is in area), move towards them
				var direction = (player.position - position).normalized()
				velocity = direction * speed
		else:
			velocity = Vector2.ZERO
			

	
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
			poison_stacks = 0
			poison_tick_timer = 0.0
		current_status = Status.NONE
		if current_status == Status.NONE:
			poison_stacks = 0
			poison_tick_timer = 0.0
		
func apply_status(status: Status, direction: Vector2, force: float, duration: float) -> void:
	if status == Status.DMG_ON_TICK:
		poison_stacks += 1
		status_timer = max(status_timer, duration) if current_status == Status.DMG_ON_TICK else duration
		current_status = Status.DMG_ON_TICK
		health_bar.modulate = Color(0.4, 1.0, 0.4)  # green tint
	else:
		if current_status == Status.DMG_ON_TICK:
			health_bar.modulate = Color.WHITE
			poison_stacks = 0
			poison_tick_timer = 0.0
		current_status = status
		status_velocity = direction * force
		status_timer = duration

#Normal movement
func _on_detection_area_body_entered(body: Node2D) -> void:
	player=GlobalData.player
	if player == body:
		player_chase=true
func _on_detection_area_body_exited(body: Node2D) -> void:
	player=null
	if player == body:
		player_chase=false
func _on_proximity_area_body_entered(body: Node2D) -> void:
	player=GlobalData.player
	if player == body:
		player_chase=false
func _on_proximity_area_body_exited(body: Node2D) -> void:
	player=GlobalData.player
	if player == body:
		player_chase=true


#Attack code
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
	


	
