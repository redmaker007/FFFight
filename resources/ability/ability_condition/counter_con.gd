extends ability_condition
class_name counter_con

@export var counter_name:String
@export var default_counter_value:int
@export var target_counter_value:int

var act_ab_ref


func condition(m):
	if act_ab_ref.counters[counter_name] == target_counter_value:
		act_ab_ref.counters[counter_name] =0
		return true
	else:
		act_ab_ref.counters[counter_name] += 1
		return false

func init(act_ab):
	act_ab.counters[counter_name] = default_counter_value
	self.act_ab_ref = act_ab
	pass
