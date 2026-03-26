extends Control

const SHOP_ENTRY_SCENE = preload("res://scene/shop_entry.tscn")

@onready var title_label: Label         = $Panel/VBox/Title
@onready var item_grid: GridContainer   = $Panel/VBox/ScrollContainer/ItemGrid
@onready var done_btn: Button           = $Panel/VBox/DoneBtn


func setup(drawn: Array, gm: Node) -> void:
	title_label.text = tr("SHOP")

	for data in drawn:
		var entry = SHOP_ENTRY_SCENE.instantiate()
		item_grid.add_child(entry)
		entry.setup(data, gm)

	done_btn.text = tr("SHOP_DONE")
	done_btn.pressed.connect(_on_done)

	Global.slide_in(self, 40.0)


func _on_done() -> void:
	SignalBus.gm_switch_state.emit("prep")
