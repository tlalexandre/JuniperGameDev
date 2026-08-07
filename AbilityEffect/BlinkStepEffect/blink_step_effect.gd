class_name BlinkStepEffect
extends AbilityEffect

const DASH_SPEED := 1000.0
const DASH_DURATION := 0.15
const IFRAME_DURATION := 0.3

func execute() -> void:
	var player := caster as Character
	var direction := _get_dash_direction(player)

	player.is_dashing = true
	player.dash_velocity = direction * DASH_SPEED
	player.is_invulnerable = true

	await get_tree().create_timer(DASH_DURATION).timeout
	player.is_dashing = false
	player.velocity = Vector2.ZERO

	var remaining_iframes = IFRAME_DURATION - DASH_DURATION
	if remaining_iframes > 0:
		await get_tree().create_timer(remaining_iframes).timeout
	player.is_invulnerable = false

	queue_free()

func _get_dash_direction(player: Character) -> Vector2:
	var input_dir := Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down"))
	if input_dir != Vector2.ZERO:
		return input_dir.normalized()
	return (player.get_global_mouse_position() - player.global_position).normalized()
