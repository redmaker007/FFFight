extends ability_condition
class_name chance_con

@export var chance:float = 0.0

func condition(m,ref):
	return randf()<chance

func get_description() -> String:
	# 确保几率为 0 时不显示，或者直接显示为百分比
	if chance <= 0:
		return ""
		
	# 把它转换成玩家熟悉的百分比格式，比如 0.25 变成 "25% chance"
	return "there is a " + str(chance * 100) + "% chance"
