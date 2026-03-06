extends GMstate

func enter_state():
	gm.group_switch_func(false)
	gm.clear_board()
	gm.show_result(false)
