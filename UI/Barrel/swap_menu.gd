extends VBoxContainer

@onready var found_icon: TextureRect = $FoundRow/FoundIcon
@onready var found_name: Label = $FoundRow/FoundName
@onready var discard_button: Button = $DiscardButton
@onready var hud_content: VBoxContainer = $"../HUDContent"
@export var click_sound: AudioStreamPlayer
@export var validate_sound: AudioStreamPlayer
@export var discard_sound: AudioStreamPlayer

var pending_bullet = null
var slot_buttons: Array = []

func _ready() -> void:
	hide()
	slot_buttons = [
		$SwapBarrel/SlotButton_0, 
		$SwapBarrel/SlotButton_1,
		$SwapBarrel/SlotButton_2,
		$SwapBarrel/SlotButton_3,
		$SwapBarrel/SlotButton_4,
		$SwapBarrel/SlotButton_5,
	]
	for i in 6:
		var idx = i
		slot_buttons[i].pressed.connect(func(): 
			click_sound.play()
			_on_slot_chosen(idx)
		)
		slot_buttons[i].process_mode = Node.PROCESS_MODE_ALWAYS  # ← add this
	
	discard_button.process_mode = Node.PROCESS_MODE_ALWAYS  # ← and this
	discard_button.pressed.connect(_on_discard)

func show_for_bullet(bullet_type) -> void:
	pending_bullet = bullet_type
	var icon_map = GlobalData.barrel_hud.bullet_icon_map
	var name_map = GlobalData.barrel_hud.bullet_name_map
	
	found_icon.texture = icon_map.get(bullet_type)
	found_name.text = name_map.get(bullet_type, "???")
	
	for i in 6:
		slot_buttons[i].texture_normal = icon_map.get(GlobalData.bullet_loadout[i])
	
	hud_content.hide()
	show()
	_pulse_slot_buttons()  # ← start pulsing after showing

func _pulse_slot_buttons() -> void:
	await get_tree().process_frame
	for btn in slot_buttons:
		btn.pivot_offset = btn.size / 2
		var tween = btn.create_tween().set_loops()  # ← tween owned by btn, which is ALWAYS
		tween.tween_property(btn, "scale", Vector2(1.12, 1.12), 0.4)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.4)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		btn.set_meta("pulse_tween", tween)

func _stop_pulse() -> void:
	for btn in slot_buttons:
		if btn.has_meta("pulse_tween"):
			btn.get_meta("pulse_tween").kill()
			btn.remove_meta("pulse_tween")
		btn.scale = Vector2.ONE

func _close() -> void:
	_stop_pulse()  # ← kill tweens before hiding
	pending_bullet = null
	hud_content.show()
	hide()
	get_tree().paused = false

func _on_slot_chosen(index: int) -> void:
	GlobalData.bullet_loadout[index] = pending_bullet
	var gun = null
	if is_instance_valid(GlobalData.player):
		gun = GlobalData.player.get_node_or_null("Gun")
	if gun != null:
		gun.loadout = GlobalData.bullet_loadout.duplicate()
		gun.BulletTypes = gun.loadout.duplicate()
		GlobalData.barrel_hud.update_icons(GlobalData.bullet_loadout)
		GlobalData.barrel_hud.update_icons_from_chamber(gun.BulletTypes)
	else:
		print("Warning: Could not find Gun node!")
	_close()

func _on_discard() -> void:
	discard_sound.play()
	_close()
