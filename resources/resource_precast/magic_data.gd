class_name MagicData
extends Resource

enum MagicType { Fire, Water, Earth, Air }

@export var id: String = ""
@export var name: String = ""
@export var icon: Texture2D
@export var mana_cost: float = 0.0
@export var damage: float = 0.0
@export var cooldown: float = 1.0
@export var magic_type: MagicType = MagicType.Fire
@export var price: int = 0


func get_display_name() -> String:
	return tr(name)


func get_display_description() -> String:
	return tr(name + "_DESC")
