extends Node


var GM

var functioning:bool
func _ready() -> void:
	
	SignalBus.connect("spawn_unit_by_name",on_spwan_unit_pressed)
	functioning = true
	GM = get_parent()

func function_switch(v:bool):
	functioning =v



func on_spwan_unit_pressed(name):
	if not functioning:
		return
	var new_unit = GM.minion_precast.instantiate()
	new_unit.ini_w_dic(GM.mm.mm[name])
	
	new_unit.z_index = 3
	new_unit.position = Vector2(50,425)
	new_unit.side = "ally"
	new_unit.add_to_group("unit")
	new_unit.add_to_group("ally")
	GM.add_child(new_unit)
	return new_unit
