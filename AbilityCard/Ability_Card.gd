extends Resource
class_name AbilityCard

enum Type { PLACEHOLDER_A, PLACEHOLDER_B, PLACEHOLDER_C, PLACEHOLDER_D }

@export var type: Type
@export var display_name: String = "Placeholder"
@export var cooldown: float = 3.0
@export var icon: Texture2D
@export var scene: PackedScene  # effect logic — placeholder for now, real effects come later
