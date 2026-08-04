extends Node2D
var dungeon:Array
@export var colors = {'R':Color.GREEN,'S':Color.YELLOW,'B':Color.RED,'L':Color.BLUE_VIOLET,'X':Color.AQUA}
@export var tilesPerRoom:int = 24
@export var pixelsPerTile:int = 64
var visualSize = 50



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_on_d_gv_2_map_ready()
	

func _on_d_gv_2_map_ready() -> void:
	dungeon = get_parent().get_dungeon()
	print(str(dungeon))
	queue_redraw()
	
func _draw() -> void:
	if dungeon.is_empty(): return
	
	for x in dungeon.size():
		for y in dungeon[x].size():
			
			var cell_key = str(dungeon[x][y])
			# Ignorar casillas vacías o cero
			if cell_key != "0" and colors.has(cell_key):
				# Convertimos a String por si acaso y buscamos en el diccionariods
				if colors.has(cell_key):
					var color = colors[cell_key]
					var pos = Vector2(x * visualSize, y * visualSize)
					var size = Vector2(visualSize, visualSize)
					# Relleno
					draw_rect(Rect2(pos, size), color, true)
					# Contorno (Grid)
					draw_rect(Rect2(pos, size), Color.BLACK, false, 4.0)
