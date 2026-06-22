extends Panel

@onready var found_icon: TextureRect = $VBoxContainer/FoundIcon
@onready var discard_button: Button = $VBoxContainer/DiscardButton
@onready var slot_buttons: Array = []

var pending_bullet = null

func _ready() -> void:
	hide()
	slot_buttons = [
		$VBoxContainer/HBoxContainer/SlotButton_0,
		$VBoxContainer/HBoxContainer/SlotButton_1,
		$VBoxContainer/HBoxContainer/SlotButton_2,
		$VBoxContainer/HBoxContainer/SlotButton_3,
		$VBoxContainer/HBoxContainer/SlotButton_4,
		$VBoxContainer/HBoxContainer/SlotButton_5,
	]
	for i in 6:
		var idx = i
		slot_buttons[i].pressed.connect(func(): _on_slot_chosen(idx))
	discard_button.pressed.connect(_on_discard)

func show_for_bullet(bullet_type) -> void:
	pending_bullet = bullet_type
	var icon_map = GlobalData.barrel_hud.bullet_icon_map
	found_icon.texture = icon_map.get(bullet_type)
	for i in 6:
		slot_buttons[i].texture_normal = icon_map.get(GlobalData.bullet_loadout[i])
	show()

func _on_slot_chosen(index: int) -> void:
	GlobalData.bullet_loadout[index] = pending_bullet
	
	# Instead of using a hardcoded path, we find the "Gun" node inside our active player instance
	var gun = null
	if is_instance_valid(GlobalData.player):
		gun = GlobalData.player.get_node_or_null("Gun")
	
	# Check if the gun was successfully found before modifying its properties
	if gun != null:
		gun.loadout = GlobalData.bullet_loadout.duplicate()
		gun.BulletTypes = gun.loadout.duplicate()
		GlobalData.barrel_hud.update_icons(GlobalData.bullet_loadout)
		GlobalData.barrel_hud.update_icons_from_chamber(gun.BulletTypes)
	else:
		print("Warning: Could not find 'Gun' node inside GlobalData.player!")
	# ----------------
	
	_close()

func _on_discard() -> void:
	_close()

func _close() -> void:
	pending_bullet = null
	hide()
	get_tree().paused = false
