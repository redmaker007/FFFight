class_name ItemData
extends Resource

@export var id: String = ""
@export var name: String = ""
@export var icon: Texture2D
@export_multiline var description: String = ""
@export var price: int = 0
@export var stackable: bool = false


func get_display_name() -> String:
	return tr(name)


func get_display_description() -> String:
	return tr(description)
