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
var _max_large_count = 0
var all_mighty_list = []
var dungeon : Array
signal map_ready

#SORRY FOR NOT TYPING COMMENTS, I FORGOT AND NOW ONLY GOD KNOWS WHAT I DID
#(and me sometimes, but not frequent)
func _ready() -> void:
	create()
	
func create():
	dungeon = []
	_init_dungeon()
	_setSpawn()
	_generate_critical_path(_spawnPoint,lenght, "R")
	_generate_boss_room()
	_generate_shop()
	_generate_large_room()
	_print_dungeon(dungeon)
	
	
	
	map_ready.emit()
	
func _init_dungeon() -> void:
	dungeon.clear()
	for x in _dimensions.x:
		dungeon.append([])
		for y in _dimensions.y:
			dungeon[x].append(0)
			
func _print_dungeon_old(dun:Array) -> void:
	
	var dungeon_as_string:String = ""
	for y in range(_dimensions.y -1, -1, -1):
		for x in _dimensions.x:
			if dun[x][y]:
				dungeon_as_string +="[" + str(dun[x][y])+"]"
			else:
				dungeon_as_string+="   "
			
		dungeon_as_string += "\n"
	print(dungeon_as_string)
	
func _print_dungeon(dun:Array) -> void:
	var dungeon_as_string:String = ""
	# Cambiamos el bucle para que vaya de 0 hacia adelante (de arriba a abajo)
	for y in _dimensions.y:
		for x in _dimensions.x:
			if dun[x][y]:
				dungeon_as_string += "[" + str(dun[x][y]) + "]"
			else:
				dungeon_as_string += "   "
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
	var boss = _check_far_away_from(_spawnPoint,dungeon)
	dungeon[boss.x][boss.y] = "B"

func _check_neightbours(room:Vector2i) -> int:
	
	var neightbour_count : int= 0
	
	var north_pos = room + Vector2i.UP
	var south_pos = room + Vector2i.DOWN
	var east_pos = room + Vector2i.RIGHT
	var west_pos = room + Vector2i.LEFT
	
	if has_room_at(north_pos,dungeon):
		neightbour_count += 1
	if has_room_at(south_pos,dungeon):
		neightbour_count += 1
	if has_room_at(east_pos,dungeon):
		neightbour_count+=1
	if has_room_at(west_pos,dungeon):
		neightbour_count+=1

	return neightbour_count

func is_valid_pos(pos:Vector2i,dun:Array) -> bool:
	return pos.x>=0 and pos.x < dun.size() and pos.y >= 0 and pos.y < dun[pos.x].size()

func has_room_at(pos:Vector2i,dun:Array) -> bool:
	if (is_valid_pos(pos,dun)):
		if (dun[pos.x][pos.y] 
		and str(dun[pos.x][pos.y]).contains("R")):
			return true
		else: return false
	return false

func _check_far_away_from(pos:Vector2i, dun : Array) -> Vector2i:
	
	var far: Vector2i = Vector2i(0,0)
	var max_distance_found : int = -1
	
	for x in dun.size():
		for y in dun[x].size():
			if str(dun[x][y]).contains("R"):
				var actual_room = Vector2i(x,y)
				var actual_distance = pos.distance_squared_to(actual_room)
				
				if (actual_distance > max_distance_found):
					max_distance_found = actual_distance
					far = actual_room
				
				
	return far
	
func _generate_large_room():
	
	all_mighty_list.clear()
	var large_room_candidates = _check_large_room_avaliability_in_dungeon([])
	large_room_candidates.sort()
	for a in large_room_candidates:
		a.sort()
	
	for i in large_room_candidates.size():
		var temp_dun = dungeon.duplicate(true)
		
		for k in large_room_candidates[i]:
			temp_dun = _add_Large_room_to_dungeon(k,temp_dun)
		
		_print_dungeon(temp_dun)
	
	if not large_room_candidates.is_empty():
		var list = _give_max_amount_of_large_options(large_room_candidates,max_large_rooms)
		if list.is_empty():
			print("Sorry, couldnt fit a large room this time")
		else:
			for x in list:
				print()
			list.shuffle()
			var op = list[0]
			for largeRoom in op:
				_add_Large_room_to_dungeon(largeRoom,dungeon)
	
#This return all the options for the dungeon
func _check_large_room_avaliability_in_dungeon(map:Array)-> Array:
	#Now we always check in the updated dungeon
	var dun = dungeon.duplicate(true)
	if not map.is_empty():
		for large_room in map:
			for section in large_room:
				dun[section.x][section.y]= "L"
				
	var room_candidates : Array = []
	var selected_rooms : Array= []
	for x in dun.size():
		for y in dun[x].size():
			#validating the actual room, just in case u know
			if(is_valid_pos(Vector2i(x,y),dun) and has_room_at(Vector2i(x,y),dun)):
				#We check every posible direction for a 2x2 room
				if(is_valid_pos(Vector2i(x+1,y),dun) and has_room_at(Vector2i(x+1,y),dun)
				and is_valid_pos(Vector2i(x,y+1),dun) and has_room_at(Vector2i(x,y+1),dun)
				and is_valid_pos(Vector2i(x+1,y+1),dun) and has_room_at(Vector2i(x+1,y+1),dun)
				):
					room_candidates.append([Vector2i(x,y),Vector2i(x+1,y),Vector2i(x,y+1),Vector2i(x+1,y+1)])
				
				if(is_valid_pos(Vector2i(x+1,y),dun) and has_room_at(Vector2i(x+1,y),dun)
				and is_valid_pos(Vector2i(x,y-1),dun) and has_room_at(Vector2i(x,y-1),dun)
				and is_valid_pos(Vector2i(x+1,y-1),dun) and has_room_at(Vector2i(x+1,y-1),dun)
				):
					room_candidates.append([Vector2i(x,y),Vector2i(x+1,y),Vector2i(x,y-1),Vector2i(x+1,y-1)])
				
				if(is_valid_pos(Vector2i(x,y-1),dun) and has_room_at(Vector2i(x,y-1),dun)
				and is_valid_pos(Vector2i(x-1,y),dun) and has_room_at(Vector2i(x-1,y),dun)
				and is_valid_pos(Vector2i(x-1,y-1),dun) and has_room_at(Vector2i(x-1,y-1),dun)
				):
					room_candidates.append([Vector2i(x,y),Vector2i(x,y-1),Vector2i(x-1,y),Vector2i(x-1,y-1)])
				
				if(is_valid_pos(Vector2i(x,y+1),dun) and has_room_at(Vector2i(x,y+1),dun)
				and is_valid_pos(Vector2i(x-1,y),dun) and has_room_at(Vector2i(x-1,y),dun)
				and is_valid_pos(Vector2i(x-1,y+1),dun) and has_room_at(Vector2i(x-1,y+1),dun)
				):
					room_candidates.append([Vector2i(x,y),Vector2i(x,y+1),Vector2i(x-1,y),Vector2i(x-1,y+1)])
		
	if not room_candidates.is_empty():
		for rooms in room_candidates:
			rooms.sort()
			if not selected_rooms.has(rooms):
				selected_rooms.append(rooms)
		
		for room in selected_rooms:
			var map_updated = map.duplicate(true)
			_max_large_count = map_updated.size()
			if max_large_rooms >= _max_large_count:
				map_updated.append(room)
				all_mighty_list.append(map_updated)
				_check_large_room_avaliability_in_dungeon(map_updated)
		
	return all_mighty_list
	
#This prints into the selected dungeon the large rooms
func _add_Large_room_to_dungeon(large_room:Array, dun:Array) -> Array:
	for room in large_room:
		dun[room.x][room.y] = "L"
	return dun

func _give_max_amount_of_large_options(LR_Candidates : Array,max_amount:int) -> Array:
	var list :Array= []
	#print(max_amount)
	for x in LR_Candidates:
		if(x.size()==max_amount):
			#print(x.size())
			list.append(x)
			print(x.size())
	if list.is_empty() and max_amount > 0:
		return _give_max_amount_of_large_options(LR_Candidates,max_amount-1)
	return list

func get_dungeon() -> Array:
	return dungeon
