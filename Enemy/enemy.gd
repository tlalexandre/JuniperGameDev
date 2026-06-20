extends CharacterBody2D

signal died

var speed = 350
var player_chase = false
var player
var current_health := 10
var max_health := 10
@onready var health_bar: ProgressBar = $HealthBar
@onready var attack_cooldown = 1
var can_attack = true
var dmg_enemy = 1

func _ready() -> void:
	player = GlobalData.player
	health_bar.set_health(current_health, max_health)
	
func _physics_process(delta: float) -> void:
	if player_chase:
		var direction = (player.position-position).normalized()
		velocity = direction * speed
	else :
		velocity = Vector2.ZERO
	move_and_slide()

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body == player:
		player_chase = true

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player:
		player_chase = false

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
	if not can_attack :
		return
	if player:
		player.take_damage(dmg_enemy)
	can_attack = false
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
	attack()
	
	
	
	
