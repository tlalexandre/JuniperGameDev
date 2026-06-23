extends Area2D

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var physical_collision: CollisionShape2D = $StaticBody2D/CollisionShape2D

var blocked: bool = false
var open: bool = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if blocked:
			return 
		open_door()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		if blocked:
			return
		close_door()

# Called by the Enemy Area to seal the room
func close_and_lock_door() -> void:
	open = false
	blocked = true
	physical_collision.set_deferred("disabled", false)
	animation.play("close")

# Helper function to open the door smoothly
func open_door() -> void:
	open = true
	physical_collision.set_deferred("disabled", true)
	animation.play("open")

# Helper function to close the door smoothly
func close_door() -> void:
	open = false
	physical_collision.set_deferred("disabled", false)
	animation.play("close")
