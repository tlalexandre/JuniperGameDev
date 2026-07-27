extends Node2D

@export var _dimensions : Vector2i = Vector2i(9,7)
@export var _spawnPoint : Vector2i = Vector2i(3,0)
@export var lenght : int = 15
@export var normal_rooms:Array[PackedScene]
@export var large_rooms:Array[PackedScene]
@export var spawn_rooms:Array[PackedScene]
@export var long_rooms:Array[PackedScene]
@export var shop_rooms:Array[PackedScene]
@export var max_large_rooms:int = 1

var dungeon : Array

func _ready() -> void:
	_init_dungeon()
	_setSpawn()
	_print_dungeon()
	_generate_critical_path(_spawnPoint,lenght, "R")
	_print_dungeon()
	_generate_boss_room()
	_print_dungeon()
	_generate_shop()
	_print_dungeon()
	_generate_large_room()
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
	dungeon[_spawnPoint.x][_spawnPoint.y] = "X"
	
	
func _generate_critical_path(from:Vector2i, lenght: int, marker : String) -> bool:
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
			#print(direction)
			dungeon[current.x][current.y] = marker
			#if lenght > 1:
			#	_branch_candidates.append(current)

			if _generate_critical_path(current, lenght -1, "R"):
				return true
			else:
			#	_branch_candidates.erase(current)
				dungeon[current.x][current.y] = 0
				current -=direction
		direction = Vector2(direction.y, -direction.x)
	return false
	
func _generate_shop():
	var shop_candidates:Array[Vector2i]
	var connections:int = 0
	for x in dungeon.size():
		for y in dungeon[x].size():
			if dungeon[x][y] and str(dungeon[x][y]).contains("R"):
				connections = _check_neightbours(Vector2i(x,y))
				if connections <= 2:
					shop_candidates.append(Vector2i(x,y))
	if(shop_candidates.size()):
		var shop = shop_candidates[randi_range(0, shop_candidates.size()-1)]
		dungeon[shop.x][shop.y] = "S"

func _generate_boss_room():
	var boss = _check_far_away_from(_spawnPoint)
	dungeon[boss.x][boss.y] = "B"

func _check_neightbours(room:Vector2i) -> int:
	
	var neightbour_count : int= 0
	
	var north_pos = room + Vector2i.UP
	var south_pos = room + Vector2i.DOWN
	var east_pos = room + Vector2i.RIGHT
	var west_pos = room + Vector2i.LEFT
	
	if has_room_at(north_pos):
		neightbour_count += 1
	if has_room_at(south_pos):
		neightbour_count += 1
	if has_room_at(east_pos):
		neightbour_count+=1
	if has_room_at(west_pos):
		neightbour_count+=1

	return neightbour_count

func is_valid_pos(pos:Vector2i) -> bool:
	return pos.x>=0 and pos.x < dungeon.size() and pos.y >= 0 and pos.y < dungeon[pos.x].size()

func has_room_at(pos:Vector2i) -> bool:
	if (is_valid_pos(pos)):
		if (dungeon[pos.x][pos.y] 
		and str(dungeon[pos.x][pos.y]).contains("R")):
			return true
			
	return false

func _check_far_away_from(pos:Vector2i) -> Vector2i:
	
	var far: Vector2i = Vector2i(0,0)
	var max_distance_found : int = -1
	
	for x in dungeon.size():
		for y in dungeon[x].size():
			if str(dungeon[x][y]).contains("R"):
				var actual_room = Vector2i(x,y)
				var actual_distance = pos.distance_squared_to(actual_room)
				
				if (actual_distance > max_distance_found):
					max_distance_found = actual_distance
					far = actual_room
				
				
	return far
	
func _generate_large_room():
	var large_room_candidates = _check_large_room_avaliability_in_dungeon()
	if(large_room_candidates):
		large_room_candidates.shuffle()
		var large_room = large_room_candidates[randi_range(0,large_room_candidates.size()-1)]
		for room in large_room:
			dungeon[room.x][room.y] = "L"
	else: print("cant do a large room master, apologies")
	
func _check_large_room_avaliability_in_dungeon()-> Array:
	var room_candidates : Array = []
	for x in dungeon.size():
		for y in dungeon[x].size():
			#validating the actual room, just in case u know
			if(is_valid_pos(Vector2i(x,y)) and has_room_at(Vector2i(x,y))):
				#We check every posible direction for a 2x2 room
				if(is_valid_pos(Vector2i(x+1,y)) and has_room_at(Vector2i(x+1,y))
				and is_valid_pos(Vector2i(x,y+1)) and has_room_at(Vector2i(x,y+1))
				and is_valid_pos(Vector2i(x+1,y+1)) and has_room_at(Vector2i(x+1,y+1))
				):
					room_candidates.append([Vector2i(x,y),Vector2i(x+1,y),Vector2i(x,y+1),Vector2i(x+1,y+1)])
				
				elif(is_valid_pos(Vector2i(x+1,y)) and has_room_at(Vector2i(x+1,y))
				and is_valid_pos(Vector2i(x,y-1)) and has_room_at(Vector2i(x,y-1))
				and is_valid_pos(Vector2i(x+1,y-1)) and has_room_at(Vector2i(x+1,y-1))
				):
					room_candidates.append([Vector2i(x,y),Vector2i(x+1,y),Vector2i(x,y-1),Vector2i(x+1,y-1)])
				
				elif(is_valid_pos(Vector2i(x,y-1)) and has_room_at(Vector2i(x,y-1))
				and is_valid_pos(Vector2i(x-1,y)) and has_room_at(Vector2i(x-1,y))
				and is_valid_pos(Vector2i(x-1,y-1)) and has_room_at(Vector2i(x-1,y-1))
				):
					room_candidates.append([Vector2i(x,y),Vector2i(x,y-1),Vector2i(x-1,y),Vector2i(x-1,y-1)])
				
				elif(is_valid_pos(Vector2i(x,y+1)) and has_room_at(Vector2i(x,y+1))
				and is_valid_pos(Vector2i(x-1,y)) and has_room_at(Vector2i(x-1,y))
				and is_valid_pos(Vector2i(x-1,y+1)) and has_room_at(Vector2i(x-1,y+1))
				):
					room_candidates.append([Vector2i(x,y),Vector2i(x,y+1),Vector2i(x-1,y),Vector2i(x-1,y+1)])
				
			
			
	return room_candidates
			
			
			
			
			
			
			
			
			
	
