extends ability_condition
class_name chance_con

@export var chance:float = 0.0

func condition(m,ref):
	if randf()<chance:
		return true
	return false
