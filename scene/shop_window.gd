extends Control

const SHOP_ENTRY_SCENE = preload("res://scene/shop_entry.tscn")

@onready var title_label: Label         = $Panel/VBox/Title
@onready var item_grid: GridContainer   = $Panel/VBox/ScrollContainer/ItemGrid
@onready var done_btn: Button           = $Panel/VBox/DoneBtn

var _budget_label: Label = null
var _gm: Node = null


func setup(drawn: Array, gm: Node) -> void:
	_gm = gm
	title_label.text = tr("SHOP")

	# 在 Title 下方插入預算顯示 label
	_budget_label = Label.new()
	_budget_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var vbox = title_label.get_parent()
	vbox.add_child(_budget_label)
	vbox.move_child(_budget_label, 1)
	refresh_budget(gm.ms.shop_budget)

	for data in drawn:
		var entry = SHOP_ENTRY_SCENE.instantiate()
		item_grid.add_child(entry)
		entry.setup(data, gm, self)


func refresh_budget(budget: float) -> void:
	if not is_instance_valid(_budget_label):
		return
	var sign_str := "-" if budget < 0 else ""
	_budget_label.text = tr("SHOP_BUDGET") + ": " + sign_str + tr("$") + str(snapped(abs(budget), 1))

	done_btn.text = tr("SHOP_DONE")
	done_btn.pressed.connect(_on_done)

	Global.slide_in(self, 40.0)


func _on_done() -> void:
	SignalBus.gm_switch_state.emit("prep")
