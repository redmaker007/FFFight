extends GMstate

func enter_state():
	gm.clear_board_by_group("base_tower")
	gm.spawn_base("ally")
	gm.spawn_base("enemy")
	gm.ms.start_level()
	gm_state_machine.switch_state("play")
