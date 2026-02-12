extends RefCounted
class_name stat_mod


var aom:bool
var stat:float

func mod(value):
	if aom:
		return value + stat
	else:
		return value*(1+stat)
