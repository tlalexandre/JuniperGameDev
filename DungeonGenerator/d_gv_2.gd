extends Node2D

@export var _dimensions : Vector2i = Vector2i(9,7)
@export var _spawnPoint : Vector2i = Vector2i(3,0)
@export var lenght : int = 15
var dungeon : Array

func _ready() -> void:
	_init_dungeon()
	_setSpawn()
	_generate_critical_path(_spawnPoint,lenght)
	_print_dungeon()
	
	
	
func _init_dungeon() -> void:
	for x in _dimensions.x:
		dungeon.append([])
		for y in _dimensions.y:
			dungeon[x].append(0)
			
func _print_dungeon() -> void:
	
	var dungeon_as_string:String = ""
	for y in range(_dimensions.y -1, -1, -1):
		for x in _dimensions.x:
			if dungeon[x][y]:
				dungeon_as_string +="[" + str(dungeon[x][y])+"]"
			else:
				dungeon_as_string+="   "
			
		dungeon_as_string += "\n"
	print(dungeon_as_string)
	
func _setSpawn() -> void:
	if _spawnPoint.x < 0 or _spawnPoint.x >= _dimensions.x:
		_spawnPoint.x = randi_range(0, _dimensions.x -1)
	if _spawnPoint.y < 0 or _spawnPoint.y >= _dimensions.y:
		_spawnPoint.y = randi_range(0, _dimensions.y -1)
	dungeon[_spawnPoint.x][_spawnPoint.y] = "S"
func _generate_critical_path(from:Vector2i, lenght: int) -> bool:
	if lenght == 0:
		return true
	var current: Vector2i = from
	var direction:Vector2i
	match randi_range(0,3):
		0:
			direction = Vector2i.UP
		1:
			direction = Vector2i.RIGHT
		2:
			direction = Vector2i.DOWN
		3:
			direction = Vector2i.LEFT
	for i in 4:
		if (current.x + direction.x >= 0 and current.x + direction.x < _dimensions.x and
			current.y + direction.y >= 0 and current.y + direction.y < _dimensions.y and
			not dungeon[current.x + direction.x][current.y+direction.y]):
			current += direction
			
			
			dungeon[current.x][current.y] = lenght

			if _generate_critical_path(current, lenght -1):
				return true
			else:
				dungeon[current.x][current.y]
				current -=direction
		direction = Vector2(direction.y, -direction.x)
	return false
	
