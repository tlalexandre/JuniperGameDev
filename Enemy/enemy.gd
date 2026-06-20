extends CharacterBody2D

var speed = 50
var player_chase = false
var player
var health = 10

func _ready() -> void:
	player = GlobalData.player
	
func _physics_process(delta: float) -> void:
	if player_chase:
		position += (player.position - position)/speed

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body == player:
		player_chase = true

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player:
		player_chase = false

func take_damage():
	print("Taking Damage ! Aie !")
	if health > 0:
		health -= 1
		print(health)
	if health <= 0:
		die()

func die():
	queue_free()
	
