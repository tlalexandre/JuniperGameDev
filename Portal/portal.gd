extends Area2D

func _on_body_entered(body: Node2D) -> void:
	
	if body.is_in_group("player"):
		body.get_node("Gun").shoot()#Thanks Jaime
		body.get_node("Gun").BulletTypes = [GlobalData.BULLET, GlobalData.BULLET, GlobalData.BULLET,GlobalData.BULLET, GlobalData.BULLET, GlobalData.BULLET]
		body.get_node("Gun").reload()
		GlobalData.barrel_hud.update_icons_from_chamber(body.get_node("Gun").BulletTypes)
		GlobalData.barrel_hud.reset()
		GlobalData.world.advance_level()
