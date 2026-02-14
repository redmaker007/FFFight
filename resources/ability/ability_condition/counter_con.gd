extends ability_condition
class_name counter_con

@export var counter_name:String
@export var default_counter_value:int
@export var target_counter_value:int




func condition(m,ref):
	if ref.counters[counter_name] == target_counter_value:
		ref.counters[counter_name] =0
		return true
	else:
		ref.counters[counter_name] += 1
		return false

func init(act_ab):
	act_ab.counters[counter_name] = default_counter_value
	pass
