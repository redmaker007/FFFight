extends PanelContainer

var h:hex_data

var lab1
var lab2

func _ready() -> void:
	$button.pressed.connect(hex_select)
	lab1 =$VBoxContainer/Label
	lab2 =$VBoxContainer/Label2
	lab1.text = h.get_pos_des()
	lab2.text = h.get_neg_des()


func hex_select():
	SignalBus.hex_select.emit(h)
