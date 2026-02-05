extends GMstate

func enter_state():
	gm.clear_board()
	gm.group_switch_func(false)
	var h_s_w = Global.hex_select_window.instantiate()
	gm.cl.add_child(h_s_w)
	SignalBus.hex_select.connect(on_select_hex)
	

func end_state():
	gm.cl.get_node("hex_select_window").queue_free()
	SignalBus.hex_select.disconnect(on_select_hex)


func on_select_hex(hex_data):
	gm_state_machine.switch_state("play")
	pass
