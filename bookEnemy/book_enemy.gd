extends Enemy

@export var large_ball_scene: PackedScene

@export var ideal_distance: float = 350.0
@export var distance_tolerance: float = 40.0
@export var book_cooldown: float = 1.8

var is_bursting: bool = false

func _process_chase(delta: float) -> void:
	if player_chase and is_instance_valid(player):
		# Force the RayCast to update its position towards the player
		line_of_sight.target_position = player.global_position - global_position
		line_of_sight.force_raycast_update()
		
		# Check if there is a direct line of sight (no walls in between)
		if line_of_sight.is_colliding() and line_of_sight.get_collider() == player:
			is_searching = false
			has_spotted_player = true
			
			# Only trigger the initial attack if we are completely free
			if not is_bursting and not is_attacking and not is_on_cooldown and not is_taking_damage:
				can_attack = true
				attack()
			
			var direction_to_player = (player.global_position - global_position).normalized()
			var current_distance = global_position.distance_to(player.global_position)
			
			if direction_to_player.x != 0:
				sprite.flip_h = direction_to_player.x < 0
			
			# Movement logic to maintain distance
			if current_distance > ideal_distance + distance_tolerance:
				velocity = direction_to_player * speed
			elif current_distance < ideal_distance - distance_tolerance:
				velocity = -direction_to_player * (speed * 0.7)
			else:
				velocity = Vector2.ZERO
		else:
			# If a wall blocks the view, stop moving and don't trigger new attacks
			velocity = Vector2.ZERO
	else:
		velocity = Vector2.ZERO
		has_spotted_player = false

func attack() -> void:
	# SAFETY CHECK 1: Ensure player tracking is active
	if not player_chase or not has_spotted_player or not is_instance_valid(player):
		return
		
	# SAFETY CHECK 2: Force a RayCast check inside the attack function itself
	line_of_sight.target_position = player.global_position - global_position
	line_of_sight.force_raycast_update()
	
	# If there is a wall between the book and the player, CANCEL the attack immediately
	if not line_of_sight.is_colliding() or line_of_sight.get_collider() != player:
		return

	# Standard parent class guard clauses
	if not can_attack or is_on_cooldown or is_attacking or is_dead or is_taking_damage:
		return

	# Lock the attack loop state
	is_bursting = true
	is_attacking = true

	# Execute attack actions
	sprite.play("Attack")
	_spawn_large_ball()

	# Wait for the animation to finish
	await get_tree().create_timer(attack_anim_duration, false, false, true).timeout
	is_attacking = false
	is_on_cooldown = true

	# Wait for the global gun cooldown
	await get_tree().create_timer(book_cooldown, false, false, true).timeout
	is_on_cooldown = false
	is_bursting = false

	# Only repeat if we still have a clear shot and are not dead/damaged
	if can_attack and not is_dead and not is_taking_damage:
		attack()

func _spawn_large_ball() -> void:
	if large_ball_scene == null or not is_instance_valid(player):
		return
		
	var ball_instance = large_ball_scene.instantiate()
	get_tree().current_scene.add_child(ball_instance)
	ball_instance.global_position = global_position
	
	var shoot_direction = (player.global_position - global_position).normalized()
	
	if ball_instance.has_method("set_direction"):
		ball_instance.set_direction(shoot_direction)
