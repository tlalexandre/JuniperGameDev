extends Enemy

func _ready() -> void:
	super()
	
	print("Fish enemy is ready!")

func _physics_process(delta: float) -> void:
	super(delta)
	
