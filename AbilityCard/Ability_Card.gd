extends CardResource
class_name AbilityCard

enum Type { PLACEHOLDER_A, PLACEHOLDER_B, PLACEHOLDER_C, PLACEHOLDER_D }

@export var type: Type
@export var mana_cost: float = 1.0
@export var scene: PackedScene  # effect logic — placeholder for now, real effects come later
