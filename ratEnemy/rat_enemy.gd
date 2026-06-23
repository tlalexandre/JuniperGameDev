extends Enemy

func _ready() -> void:
	super()
	
	print("Rat enemy is ready!")

func _physics_process(delta: float) -> void:
	super(delta)
	
