extends RefCounted
class_name active_debuff

var data:debuff

var time_left:float
var stacks

var mods =[]


var debuff_mod


func start(tar):
	time_left = data.duration
	if !data.stat_change:
		return
	if data.percentage_change:
		var m = tar.add_mod(data.stat_str,data.percentage_change,false)
		mods.append(m)
	if data.addition_change:
		var n = tar.add_mod(data.stat_str,data.addition_change,true)
		mods.append(n)

func end(tar):
	var temp_l =[]
	for m in mods:
		for i in tar.stat_mod_l[data.stat_str]:
			if m == i:
				temp_l.append(i)
	for i in temp_l:
		tar.stat_mod_l[data.stat_str].erase(i)
