extends GMstate

func enter_state():
	
	gm.hs.deactive_all_hex()
	var t_hex_list =[]
	var all_hex_list = HexAutoload.hex_dic.keys()
	for i in range(min(3,all_hex_list.size())):
		var random_key = all_hex_list.pick_random()
		all_hex_list.erase(random_key)
		t_hex_list.append(HexAutoload.hex_dic[random_key])
	gm.clear_board()
	gm.group_switch_func(false)
	var h_s_w = Global.hex_select_window.instantiate()
	gm.cl.add_child(h_s_w)
	h_s_w.set_hex(t_hex_list)
	SignalBus.hex_select.connect(on_select_hex)
	

func end_state():
	gm.hs.active_all_hex()
	gm.cl.get_node("hex_select_window").queue_free()
	SignalBus.hex_select.disconnect(on_select_hex)


func on_select_hex(h:hex_data):
	for sub_h in h.positive_hex_list:
		gm.hs.add_hex(sub_h)
	for sub_h in h.negative_hex_list:
		gm.hs.add_hex(sub_h)
	gm_state_machine.switch_state("play")
	
	pass
