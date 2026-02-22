extends GMstate


func enter_state():
	gm.group_switch_func(false)
	get_tree().paused = true

func end_state():
	gm.group_switch_func(true)
	get_tree().paused = false
