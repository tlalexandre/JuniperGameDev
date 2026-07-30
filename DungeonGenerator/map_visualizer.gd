extends Node2D
var dungeon:Array
@export var colors = {'R':Color.SKY_BLUE,'S':Color.GREEN,'B':Color.RED,'L':Color.YELLOW,'X':Color.AQUA}
@export var tilesPerRoom:int = 24
@export var pixelsPerTile:int = 64
var visualSize = 64



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dungeon = get_parent().get_dungeon()
	
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
