extends Node

const END_SCREEN = preload("uid://d3f2e6mi28i8q")
@onready var control: Control = $Control
@onready var label: Label = $Control/Label
var on_pause

var end_screen_instance

func _ready() -> void:
	end_screen_instance = END_SCREEN.instantiate()
	add_child(end_screen_instance)
	# Removed setup_level from here to let World manage the timing

func setup_level() -> void:
	# Connect death signal to the freshly updated player reference
	if is_instance_valid(GlobalData.player):
		if GlobalData.player.died.is_connected(_on_player_died):
			GlobalData.player.died.disconnect(_on_player_died)
		GlobalData.player.died.connect(_on_player_died)

func _on_player_died() -> void:
	end_screen_instance.show_overlay(EndScreen.OverlayState.LOST)

func win():
	end_screen_instance.show_overlay(EndScreen.OverlayState.WON)

func pause():
	end_screen_instance.show_overlay(EndScreen.OverlayState.PAUSED)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		pause()
