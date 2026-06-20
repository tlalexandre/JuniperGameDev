extends ProgressBar


func set_health(current:float, max_health:float)-> void:
	max_value = max_health
	value = current
