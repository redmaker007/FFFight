extends Node

var debuff_func_map ={
	"slow":Callable(self,"slow_debuff")
}

var debuff_stat_map ={
	"slow":{
		1:[.70,1],
		2:[.70,1.5],
		3:[.65,1.5],
		4:[.65,2],
		5:[.60,2.5],
	}
}

func slow_debuff(target,level):
	if target.debuff.has("slow"):
		return
	target.debuff["slow"]= true
	
	var l = min(level,5)
	var o_speed = target.speed
	
	target.speed= o_speed*debuff_stat_map["slow"][l][0]
	await get_tree().create_timer(debuff_stat_map["slow"][l][1]).timeout
	target.debuff.erase("slow")
	target.speed = o_speed
	
