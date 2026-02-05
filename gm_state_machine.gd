extends Node



var current_state :String= ""



var state_map = {}



func _ready() -> void:
	for s in get_children():
		state_map[s.name] = s

func switch_state(state_name):
	state_map[current_state].end_state()
	current_state = state_name
	state_map[current_state].enter_state()
	pass
