extends GMstate



func enter_state():
	gm.group_switch_func(true)
	gm.es.reset_wave_timer()
	SignalBus.unit_death.connect(check_base_death)

func end_state():
	if SignalBus.unit_death.is_connected(check_base_death):
		SignalBus.unit_death.disconnect(check_base_death)

func check_base_death(unit):
	if unit.is_in_group("base"):
		if unit.side == "ally":
			gm_state_machine.switch_state("gameover")
		else:
			gm_state_machine.switch_state("hex")
