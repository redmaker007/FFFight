extends Node

func enter_state():
	get_parent().group_stop_func()
	get_parent().clear_board()
