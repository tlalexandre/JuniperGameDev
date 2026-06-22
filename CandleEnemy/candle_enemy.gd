extends Enemy

func _ready() -> void:
	super()
	
	print("Candle enemy is ready!")

func _physics_process(delta: float) -> void:
	super(delta)
	
