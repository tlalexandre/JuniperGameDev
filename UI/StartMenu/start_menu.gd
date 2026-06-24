extends Control

@onready var barrel_ring = $BarrelRing
@onready var music_button: Button = $PanelContainer/VBoxContainer/MusicButton
const GAME = preload("uid://bfgnlkfctn1gn")

func _ready() -> void:
	barrel_ring.spin_idle()
	_update_music_button()

func _process(delta: float) -> void:
	barrel_ring.spin_idle()

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Game/Game.tscn")

func _on_music_button_pressed() -> void:
	GameManager.toggle_mute()
	_update_music_button()

func _update_music_button() -> void:
	music_button.text = "Music: OFF" if GameManager.is_muted else "Music: ON"

func _on_quit_button_pressed() -> void:
	get_tree().quit()
