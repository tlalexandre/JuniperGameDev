extends Node2D

@export var levels : Array[PackedScene] = []

var current_level_index : int = 0
var current_level_instance : Node = null

func _enter_tree() -> void:
	# Assign the world reference as before
	GlobalData.world = self

func _ready() -> void:
	# FORCE GlobalData to find the new player instance after reloading
	# This fixes the camera and reference break without touching GlobalData's script
	if has_node("Player"):
		GlobalData.player = get_node("Player")
	
	# Connect the GameManager to the fresh player instance
	GameManager.setup_level()
	
	# Load the first level
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

func advance_level() -> void:
	load_level(current_level_index + 1)
