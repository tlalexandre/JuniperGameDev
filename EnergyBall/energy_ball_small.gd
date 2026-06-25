extends Area2D

@export var speed: float = 350.0
@export var damage: float = 2.0

var direction: Vector2 = Vector2.ZERO

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
