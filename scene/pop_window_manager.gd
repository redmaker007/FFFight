extends Node

@onready var gm = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.open_unit_gallery.connect(open_unit_gallery)
	pass

func open_unit_gallery():
	SignalBus.gm_switch_state.emit("pause")
	var ugw = Global.unit_gallery_window.instantiate()
	ugw.z_index = 100
	gm.cl.add_child(ugw)
