extends Area2D

# NEW: Signal to notify the DungeonGenerator when the player crosses
signal player_crossed

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var physical_collision: CollisionShape2D = $StaticBody2D/CollisionShape2D

var blocked: bool = false
var open: bool = false

func _on_body_entered(body: Node2D) -> void:
	print("¡Algo tocó la puerta!: ", body.name) # <-- AÑADE ESTO
	if body.is_in_group("Player") or body.is_in_group("player"):
		print("¡Es el jugador! Abriendo puerta y mandando señal...") # <-- AÑADE ESTO
		if blocked:
			return 
		open_door()
		player_crossed.emit()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player") or body.is_in_group("player"):
		if blocked:
			return
		close_door()

func close_and_lock_door() -> void:
	open = false
	blocked = true
	physical_collision.set_deferred("disabled", false)
	animation.play("close")

func open_door() -> void:
	open = true
	physical_collision.set_deferred("disabled", true)
	animation.play("open")

func close_door() -> void:
	open = false
	physical_collision.set_deferred("disabled", false)
	animation.play("close")
