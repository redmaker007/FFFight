extends RefCounted
class_name active_ability

var ab_data:ability_data

var counters = {}


func use_ability(m:Node2D):
	ab_data.condition_then_process(m,self)
	pass
	

func init():
	ab_data.init_ability(self)
