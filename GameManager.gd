extends Node

const END_SCREEN = preload("uid://d3f2e6mi28i8q")
@onready var control: Control = $Control
@onready var label: Label = $Control/Label
var on_pause

var enemies
var enemies_number
var end_screen_instance
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	end_screen_instance = END_SCREEN.instantiate()
	add_child(end_screen_instance)
	setup_level()


func setup_level() -> void:
	enemies = get_tree().get_nodes_in_group("enemies")
	enemies_number = enemies.size()
	for enemy in enemies:
		print(enemy)
		enemy.died.connect(_on_enemy_died)
	GlobalData.player.died.connect(_on_player_died)

func _on_enemy_died() -> void:
	print("enemy died")
	enemies_number -= 1
	if enemies_number == 0:
		win()

func _on_player_died()-> void:
	end_screen_instance.show_overlay(EndScreen.OverlayState.LOST)

func win():
	end_screen_instance.show_overlay(EndScreen.OverlayState.WON)

func pause():
	end_screen_instance.show_overlay(EndScreen.OverlayState.PAUSED)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") :
		pause()

			

		
