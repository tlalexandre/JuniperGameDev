extends Area2D

@export var doors_to_close: Array[Area2D] = []
@export var room_enemies: Array[CharacterBody2D] = [] # Tracks your unchanged enemies
@export var chest_scene: PackedScene 

var room_activated: bool = false

func _ready() -> void:
	# We turn off processing on frame 1 so it doesn't waste CPU 
	# until the player actually steps inside the room.
	set_process(false)
	
	print("--- Room Initialization Status ---")
	print("Enemies tracked in Inspector: ", room_enemies.size())
	print("---------------------------------")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not room_activated:
		room_activated = true
		print("Player entered encounter zone! Shutting doors...")
		
		# Lock down every door inside the array
		for door in doors_to_close:
			if door != null:
				door.close_and_lock_door()
		
		# Turn on processing so it starts checking the enemies every frame
		set_process(true)

func _process(delta: float) -> void:
	if not room_activated:
		return
		
	var alive_enemies: int = 0
	
	# Go through your array and count how many enemies are still physically valid/alive
	for enemy in room_enemies:
		if is_instance_valid(enemy) and enemy.is_inside_tree():
			alive_enemies += 1
			
	# As soon as the count hits 0, unlock the room!
	if alive_enemies == 0:
		set_process(false) # Stop processing immediately to save memory
		complete_challenge()

func complete_challenge() -> void:
	print("Victory! No enemies left. Spawning chest and opening doors.")
	
	# 1. Unlock and automatically open doors
	for door in doors_to_close:
		if door != null:
			door.blocked = false
			door.open_door()
	
	# 2. Instantiate and place your chest scene at the center of this Area2D
	if chest_scene != null:
		var chest_instance = chest_scene.instantiate()
		get_parent().add_child(chest_instance) 
		chest_instance.global_position = self.global_position
		
	# 3. Safely delete this area zone so it doesn't trigger again
	queue_free()
