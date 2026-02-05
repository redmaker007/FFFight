extends Node



var current_state :String= ""
@export var default_state:String = ""


var state_map = {}



func _ready() -> void:
	await get_tree().process_frame
	var gm = get_parent()
	for s in get_children():
		state_map[s.state_name] = s
		s.gm = gm
		s.gm_state_machine = self
	switch_state(default_state)
	

func switch_state(state_name):
	print("enter: ",state_name)
	if current_state !="":
		state_map[current_state].end_state()
	current_state = state_name
	state_map[current_state].enter_state()
	pass

func single_state_process():
	state_map[current_state].state_process()
