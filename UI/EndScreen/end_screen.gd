class_name EndScreen
extends CanvasLayer

@onready var label: Label = $Control/PanelContainer/VBoxContainer/Label
@onready var control: Control = $Control
@onready var resume_button: Button = $Control/PanelContainer/VBoxContainer/ResumeButton
@onready var score_value: Label = $Control/PanelContainer/VBoxContainer/StatsRow/ScoreCard/ScoreValue
@onready var floor_value: Label = $Control/PanelContainer/VBoxContainer/StatsRow/FloorCard/FloorValue
@onready var music_button: Button = $Control/PanelContainer/VBoxContainer/MusicButton


var on_pause = false
enum OverlayState {PAUSED, WON, LOST}
var current_state: OverlayState

func _ready() -> void:
	control.visible = false

func show_overlay(state: OverlayState) -> void:
	current_state = state
	control.visible = true
	get_tree().paused = true
	score_value.text = str(GlobalData.score)
	floor_value.text = str(GlobalData.floor_number)
	
	
	match state:
		OverlayState.PAUSED:
			label.text = "Pause"
			resume_button.text = "Resume"
		OverlayState.WON:
			label.text = "You Won"
			resume_button.text = "Restart"
		OverlayState.LOST:
			label.text = "You lost, hahaha"
			resume_button.text = "Restart"

func _on_resume_button_pressed() -> void:
	match current_state:
		OverlayState.PAUSED:
			get_tree().paused = false
			control.visible = false
		OverlayState.WON, OverlayState.LOST:
			get_tree().paused = false
			control.visible = false
			GlobalData.score = 0
			GlobalData.floor_number = 0
			GlobalData.world.load_level(0)

func _on_quit_button_pressed() -> void:
	get_tree().paused = false
	control.visible = false
	get_tree().change_scene_to_file("res://UI/StartMenu/start_menu.tscn")



func _on_music_button_pressed() -> void:
	music_button.text = "Music: OFF" if GameManager.is_muted else "Music: ON"
	GameManager.toggle_mute()
