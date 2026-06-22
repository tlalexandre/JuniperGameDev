extends Bullet

const EXPLOSION = preload("uid://djok2etes861s")

@export var explosion_radius: float = 80.0
@export var explosion_damage: int = 2
var _show_debug_circle := false

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		_explode()
		await get_tree().create_timer(0.3).timeout
		queue_free()

func _explode() -> void:
	var space = get_world_2d().direct_space_state
	var shape = CircleShape2D.new()
	shape.radius = explosion_radius

	var params = PhysicsShapeQueryParameters2D.new()
	params.shape = shape
	params.transform = Transform2D(0, global_position)
	params.collision_mask = 2  # ← your enemies layer, check this

	var results = space.intersect_shape(params)
	for result in results:
		var hit = result["collider"]
		if hit.is_in_group("enemies") and hit.is_in_group("book"):
			hit.take_damage(explosion_damage*2)
		elif(hit.is_in_group("enemies")):
			hit.take_damage(explosion_damage)
	_show_debug_circle = true
	queue_redraw()  # triggers _draw() this frame
	_play_explosion_vfx()
	
func _draw() -> void:
	if _show_debug_circle:
		draw_circle(Vector2.ZERO, explosion_radius, Color(1, 0.3, 0, 0.4))
		
func _play_explosion_vfx() -> void:
	var vfx = EXPLOSION.instantiate()
	GlobalData.world.add_child(vfx)
	vfx.global_position = global_position
	var sprite_half_width = 16.0  # 32px frame / 2
	var target_scale = explosion_radius / sprite_half_width
	vfx.scale = Vector2(target_scale, target_scale)
