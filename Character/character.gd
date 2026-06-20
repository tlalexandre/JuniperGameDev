extends CharacterBody2D

@onready var health_bar: ProgressBar = $HealthBar

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var last_direction = Vector2.DOWN
var max_health := 20
var current_health := 20

func _ready():
	health_bar.set_health(current_health, max_health)

func _physics_process(delta: float) -> void:

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var horizontal_direction := Input.get_axis("left", "right")
	var vertical_direction := Input.get_axis("up","down")
	if horizontal_direction:
		velocity.x = horizontal_direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if vertical_direction:
		velocity.y = vertical_direction * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
		
	#Calculation of last direction to allow have a direction for the dodge
	var input_dir := Vector2(horizontal_direction, vertical_direction)
	
	if input_dir != Vector2.ZERO:
		last_direction = input_dir.normalized()
	if Input.is_action_just_pressed("dodge"):
		var dodge_dir := input_dir
		if input_dir != Vector2.ZERO :
			velocity += dodge_dir * 20 * SPEED
		else :	
			velocity += last_direction * 20 * SPEED
	move_and_slide()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		get_node("Gun").shoot()
		
func take_damage(amount: float):
	print("Player Taking Damage ! Aie !")
	current_health -= amount
	health_bar.set_health(current_health,max_health)
	if current_health <= 0:
		die()

func die():
	queue_free()
	
	
