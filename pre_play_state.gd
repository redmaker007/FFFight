extends GMstate

func enter_state():
	gm.group_switch_func(false)
	gm.ms.reset_bank()
	gm.clear_board()
	gm_state_machine.switch_state("hex")
