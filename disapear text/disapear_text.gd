extends Area2D


func _on_body_exited(body: Node2D) -> void:
	self.get_parent().queue_free()
	
