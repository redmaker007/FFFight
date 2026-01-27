extends Node


var GM
func _ready() -> void:
	SignalBus.connect("spawn_unit_by_name",on_spwan_unit_pressed)
	GM = get_parent()




func on_spwan_unit_pressed(name) -> void:
	var new_unit = GM.minion_precast.instantiate()
	new_unit.ini_w_dic(GM.mm.mm[name])
	
	new_unit.z_index = 3
	new_unit.position = Vector2(50,425)
	new_unit.side = "ally"
	new_unit.add_to_group("unit")
	new_unit.add_to_group("ally")
	GM.add_child(new_unit)
	
