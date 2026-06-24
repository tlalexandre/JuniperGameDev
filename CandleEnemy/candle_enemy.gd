extends Enemy

@export var fireball_scene: PackedScene

@export var ideal_distance: float = 300.0
@export var distance_tolerance: float = 50.0

@export var burst_count: int = 5
@export var time_between_shots: float = 0.5
@export var burst_cooldown: float = 2.0

# NEW VARIABLE: Prevents multiple attack loops from overlapping in _physics_process
var is_bursting: bool = false

func _process_chase(delta: float) -> void:
	if player_chase and is_instance_valid(player):
		line_of_sight.target_position = player.global_position - global_position
		line_of_sight.force_raycast_update()
		
		if line_of_sight.is_colliding() and line_of_sight.get_collider() == player:
			is_searching = false
			has_spotted_player = true
			
			# MODIFIED CHECK: Now safely uses 'is_bursting' to guarantee only ONE loop runs at a time
			if not is_bursting and not is_attacking and not is_on_cooldown and not is_taking_damage:
				can_attack = true
				attack()
			
			var direction_to_player = (player.global_position - global_position).normalized()
			var current_distance = global_position.distance_to(player.global_position)
			
			if direction_to_player.x != 0:
				sprite.flip_h = direction_to_player.x < 0
			
			if current_distance > ideal_distance + distance_tolerance:
				velocity = direction_to_player * speed
			elif current_distance < ideal_distance - distance_tolerance:
				velocity = -direction_to_player * (speed * 0.8)
			else:
				velocity = Vector2.ZERO
		else:
			velocity = Vector2.ZERO
	else:
		velocity = Vector2.ZERO
		has_spotted_player = false

func attack() -> void:
	if not player_chase or not has_spotted_player:
		return
		
	if not can_attack or is_on_cooldown or is_attacking or is_dead or is_taking_damage:
		return

	# Lock the entire burst mechanism
	is_bursting = true
	is_attacking = true

	for i in range(burst_count):
		# If the enemy gets interrupted or damaged, break the current firing sequence
		if is_dead or is_taking_damage or not is_instance_valid(player):
			break
			
		sprite.play("Attack")
		_spawn_fireball()
		
		await get_tree().create_timer(time_between_shots, false, false, true).timeout

	is_attacking = false
	is_on_cooldown = true

	# Wait for the full cooldown before allowing 'is_bursting' to clear
	await get_tree().create_timer(burst_cooldown, false, false, true).timeout
	
	is_on_cooldown = false
	# Unlock the mechanism so a brand new clean loop can start when ready
	is_bursting = false 

	# If the player is still in range, continue onto the next clean loop
	if can_attack and not is_dead and not is_taking_damage:
		attack()

func _spawn_fireball() -> void:
	if fireball_scene == null or not is_instance_valid(player):
		return
		
	var fireball_instance = fireball_scene.instantiate()
	get_tree().current_scene.add_child(fireball_instance)
	fireball_instance.global_position = global_position
	var shoot_direction = (player.global_position - global_position).normalized()
	
	if fireball_instance.has_method("set_direction"):
		fireball_instance.set_direction(shoot_direction)
	elif "direction" in fireball_instance:
		fireball_instance.direction = shoot_direction
