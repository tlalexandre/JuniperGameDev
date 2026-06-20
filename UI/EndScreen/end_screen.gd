class_name EndScreen
extends CanvasLayer

@onready var label: Label = $Control/Label
@onready var control: Control = $Control
@onready var resume_button: Button = $Control/ResumeButton


var on_pause = false
enum OverlayState {PAUSED,WON,LOST}
var current_state: OverlayState

func _ready() -> void:
	control.visible = false

func show_overlay(state: OverlayState) -> void:
	current_state = state
	control.visible = true
	get_tree().paused = true
	#state = OverlayState
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
			get_tree().reload_current_scene()
			control.visible = false


func _on_quit_button_pressed() -> void:
	get_tree().quit()
