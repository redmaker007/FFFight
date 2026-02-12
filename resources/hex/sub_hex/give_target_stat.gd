extends sub_hex_data
class_name give_target_stat

@export var stat_str:String
@export var percentage_change:float =0
@export var addition_change:float =0

@export var target_selec:target_selector

func get_description():
	return "gain "+str(percentage_change*100)+"% and "+str(addition_change)+" of "+str(stat_str)+"."

func on_unit_spawn(m):
	var tar = target_selec.tar_select(m)
	if m in tar:
		if percentage_change:
			m.add_mod(stat_str,percentage_change,false)
		if addition_change:
			m.add_mod(stat_str,addition_change,true)
	pass
