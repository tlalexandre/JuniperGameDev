extends Node2D

@export var levels : Array[PackedScene] = []

var current_level_index : int = 0
var current_level_instance : Node = null

func _enter_tree() -> void:
	# 1. Assign the world reference immediately
	GlobalData.world = self

func _ready() -> void:
	# Load the first level right away
	if levels.size() > 0:
		load_level(0)
	else:
		print("Please add your level scenes to the 'Levels' Array in the Inspector.")

func load_level(index : int) -> void:
	if index >= levels.size():
		GameManager.win()
		return
		
	if is_instance_valid(current_level_instance):
		current_level_instance.queue_free()
		
	current_level_index = index
	var level_scene = levels[index]
	current_level_instance = level_scene.instantiate()
	
	add_child(current_level_instance)
	print("Level loaded successfully: ", index)
	
	# --- THE INSTANT REGISTER FIX ---
	# We wait a single frame to allow the newly instantiated level 
	# and its nodes (including the Player) to completely enter the tree.
	await get_tree().process_frame
	
	var found_player = get_tree().get_first_node_in_group("player")
	if found_player:
		GlobalData.player = found_player
		print("Player found via group and registered in GlobalData!")
	else:
		print("Warning: No node found in group 'player'!")
		
	# Setup the GameManager now that the player is 100% guaranteed to be found
	GameManager.setup_level()
	# ---------------------------------

func advance_level() -> void:
	load_level(current_level_index + 1)
