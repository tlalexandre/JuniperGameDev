extends Area2D

func _on_body_entered(body: Node2D) -> void:
	
	if body.is_in_group("player"):
		body.get_node("Gun").shoot()#Thanks Jaime
	GlobalData.world.advance_level()
