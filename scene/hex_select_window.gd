extends PanelContainer

var hex :Array[hex_data]=[]

var select_butts=[]

var hex_select_button = preload("res://scene/hex_select_button.tscn")




func set_hex(h_list):
	for i in range(len(h_list)):
		var b = hex_select_button.instantiate()
		b.h = h_list[i]
		$VBoxContainer/HBoxContainer.add_child(b)
	pass
