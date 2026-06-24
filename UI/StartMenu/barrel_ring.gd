extends Control


var spin_tween : Tween
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func spin_idle() -> void:
	if spin_tween:
		spin_tween.kill()
	spin_tween = create_tween().set_loops()  # loops forever
	spin_tween.tween_property(self, "rotation", rotation + TAU, 3.0)\
		.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
