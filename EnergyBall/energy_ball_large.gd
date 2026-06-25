extends Area2D

@export var small_ball_scene: PackedScene
@export var speed: float = 300.0
@export var damage: float = 5.0
@export var time_before_explosion: float = 0.4

var direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	# Start the countdown to explode and split into 6 small balls
	await get_tree().create_timer(time_before_explosion, false).timeout
	explode()

func _physics_process(delta: float) -> void:
	if direction != Vector2.ZERO:
		global_position += direction * speed * delta

func set_direction(dir: Vector2) -> void:
	direction = dir
	rotation = dir.angle()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body == GlobalData.player:
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()
	
	queue_free()

func explode() -> void:
	if is_queued_for_deletion():
		return
		
	if small_ball_scene != null:
		# 6 directions in radians (360 degrees divided into 6 pieces = 60 degrees each)
		for i in range(6):
			var angle = i * (PI / 3.0) # PI / 3 is exactly 60 degrees
			var spawn_direction = Vector2(cos(angle), sin(angle)).normalized()
			
			var small_ball = small_ball_scene.instantiate()
			get_tree().current_scene.add_child(small_ball)
			
			# Spawn at the large ball's current explosion center
			small_ball.global_position = global_position
			
			if small_ball.has_method("set_direction"):
				small_ball.set_direction(spawn_direction)
				
	# Delete the large ball after spawning the children
	queue_free()
