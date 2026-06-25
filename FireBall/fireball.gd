extends Area2D

@export var speed: float = 400.0
@export var damage: float = 1.0

var direction: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	# Move the fireball forward if a direction is set
	if direction != Vector2.ZERO:
		global_position += direction * speed * delta

# This function is called by the Candle enemy upon spawning
func set_direction(dir: Vector2) -> void:
	direction = dir
	rotation = dir.angle()

# Connect this function to the "body_entered" signal of this Area2D
func _on_body_entered(body: Node2D) -> void:
	# If it hits the player, deal damage using the parent's damage system
	if body.is_in_group("player") or body == GlobalData.player:
		if body.has_method("take_damage"):
			body.take_damage(damage)
		
		# Destroy the fireball after hitting the player
		queue_free()
