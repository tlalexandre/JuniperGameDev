extends CardResource
class_name BulletCard

enum Type {BASIC, FIRE, ICE, AIR, ELECTRICITY, POISON }

@export var type: Type
@export var scene: PackedScene
