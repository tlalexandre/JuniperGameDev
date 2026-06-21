class_name Bullet
extends CharacterBody2D



@export var speed : int = 400
var target_position
var despawn_time = 1
var bullet_dmg = 1

func _ready() -> void:
	rotation = target_position.angle() + deg_to_rad(90)
	despawn()
	
func _physics_process(delta: float) -> void:
	velocity = target_position * speed
	move_and_slide()
	
func despawn() -> void:
	await get_tree().create_timer(despawn_time).timeout
	queue_free()




func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):	
		body.take_damage(bullet_dmg)
		queue_free()
