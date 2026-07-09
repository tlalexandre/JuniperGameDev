extends Node2D

@export var available_rooms: Array[PackedScene] = []
@export var max_rooms: int = 6

# This dictionary stores LIVE nodes safely in memory (not necessarily in the screen tree)
var dungeon_grid: Dictionary = {}
var current_grid_coords: Vector2 = Vector2.ZERO
var current_room_node: Node2D = null

func _ready() -> void:
	randomize()
	generate_procedural_dungeon()
	
	# FORCE START: Load the spawn room at (0,0)
	current_grid_coords = Vector2.ZERO
	load_room_at_coords(current_grid_coords)

func generate_procedural_dungeon() -> void:
	if available_rooms.is_empty():
		return
		
	dungeon_grid.clear()
	
	# 1. Instantiate the Spawn room in memory (Do NOT add_child yet!)
	var spawn_instance = available_rooms[0].instantiate()
	dungeon_grid[Vector2.ZERO] = spawn_instance
	
	var queue: Array[Vector2] = [Vector2.ZERO]
	var rooms_count: int = 1
	var directions = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	
	while rooms_count < max_rooms and not queue.is_empty():
		var current_check = queue.pop_front()
		directions.shuffle()
		
		for dir in directions:
			if rooms_count >= max_rooms:
				break
				
			var target_cell = current_check + dir
			
			if not dungeon_grid.has(target_cell) and randf() > 0.5:
				var random_index = randi_range(1, available_rooms.size() - 1)
				
				# 2. Instantiate procedural rooms in memory only (Safe from overlapping!)
				var room_instance = available_rooms[random_index].instantiate()
				dungeon_grid[target_cell] = room_instance
				
				rooms_count += 1
				queue.append(target_cell)
				
		if queue.is_empty() and rooms_count < max_rooms:
			queue.append(dungeon_grid.keys().pick_random())

func load_room_at_coords(coords: Vector2) -> void:
	# 1. DISCONNECT OLD ROOM: Remove it from the active screen, but keep it in memory
	if current_room_node != null:
		if current_room_node.get_parent() == self:
			remove_child(current_room_node)
		
	if dungeon_grid.has(coords):
		current_grid_coords = coords
		
		# 2. RETRIEVE ROOM: Get the live room node from our grid dictionary
		current_room_node = dungeon_grid[coords]
		
		# 3. CONNECT TO SCREEN: Add it back to the game scene tree right now
		add_child(current_room_node)
		
		# Forcibly snap its transform values so it aligns perfectly centered
		current_room_node.global_position = Vector2.ZERO
		current_room_node.rotation_degrees = 0.0
		current_room_node.scale = Vector2.ONE
		
		validate_room_doors()
		setup_room_doors()

# --- (The rest of the door validation and teleport logic remains identical) ---
func validate_room_doors() -> void:
	if current_room_node == null: return
	var doors_container = current_room_node.get_node_or_null("DoorPositions")
	if not doors_container: return
	for direction_folder in doors_container.get_children():
		var dir_name = direction_folder.name
		var check_coords = current_grid_coords
		match dir_name:
			"North": check_coords += Vector2.UP
			"South": check_coords += Vector2.DOWN
			"East":  check_coords += Vector2.RIGHT
			"West":  check_coords += Vector2.LEFT
		if not dungeon_grid.has(check_coords):
			direction_folder.visible = false
			for child in direction_folder.get_children():
				child.visible = false
				if child.has_node("StaticBody2D/CollisionShape2D"):
					child.get_node("StaticBody2D/CollisionShape2D").set_deferred("disabled", false)
		else:
			direction_folder.visible = true
			for child in direction_folder.get_children():
				child.visible = true

func setup_room_doors() -> void:
	if current_room_node == null: return
	var doors_container = current_room_node.get_node_or_null("DoorPositions")
	if not doors_container: return
	for direction_folder in doors_container.get_children():
		if not direction_folder.visible: continue
		for marker in direction_folder.get_children():
			if marker is Marker2D:
				for child in marker.get_children():
					if child.has_signal("player_crossed"):
						if not child.player_crossed.is_connected(_on_door_crossed):
							child.player_crossed.connect(_on_door_crossed.bind(direction_folder.name))

func _on_door_crossed(direction_name: String) -> void:
	var target_coords = current_grid_coords
	match direction_name:
		"North": target_coords += Vector2.UP
		"South": target_coords += Vector2.DOWN
		"East":  target_coords += Vector2.RIGHT
		"West":  target_coords += Vector2.LEFT
	if dungeon_grid.has(target_coords):
		load_room_at_coords(target_coords)
		teleport_player_to_opposite_door(direction_name)

func teleport_player_to_opposite_door(crossed_direction: String) -> void:
	var opposite_map = {"North": "South", "South": "North", "East": "West", "West": "East"}
	var target_folder_name = opposite_map[crossed_direction]
	var doors_container = current_room_node.get_node_or_null("DoorPositions")
	if doors_container:
		var target_folder = doors_container.get_node_or_null(target_folder_name)
		if target_folder:
			var target_marker: Marker2D = null
			for child in target_folder.get_children():
				if child is Marker2D:
					target_marker = child
					break
			if target_marker:
				var player = get_tree().get_first_node_in_group("Player")
				if not player: player = get_tree().get_first_node_in_group("player")
				if player: player.global_position = target_marker.global_position
