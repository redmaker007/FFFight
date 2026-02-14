extends Node



var stat_dic ={
	"speed"= 100.0,
	"hp" =100.0,
	"max_hp" =100.0,
	"att" =10.0,
	"att_r" =50.0,
	"att_CD" =1.0,
	}


var stat_mod_l ={
"speed"=[],
"hp" =[],
"max_hp" =[],
"att" =[],
"att_r" =[],
"att_CD" =[],
}

#get_stat 用来获得运算过后的数值
func get_moded_stat(stat_str):
	var calculated_value = stat_dic[stat_str]
	for m in stat_mod_l[stat_str]:
		if m.aom:
			calculated_value = m.mod(calculated_value)
	for m in stat_mod_l[stat_str]:
		if !m.aom:
			calculated_value = m.mod(calculated_value)
	return calculated_value

func add_mod(stat_str,value,aom):
	var mod = stat_mod.new()
	mod.aom =aom
	mod.stat = value
	stat_mod_l[stat_str].append(mod)
	return mod
