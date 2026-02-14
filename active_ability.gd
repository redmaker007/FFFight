extends RefCounted
class_name active_ability

var ab_data:ability_data

var counters = {}

func init():
	ab_data.init_ability(self)
