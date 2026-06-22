extends Enemy

func _ready() -> void:
	super()
	
	print("Ghost enemy is ready!")

func _physics_process(delta: float) -> void:
	super(delta)
	
