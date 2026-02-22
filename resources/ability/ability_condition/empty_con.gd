extends ability_condition
class_name empty_con



func condition(m,ref):
	return true

func get_description() -> String:
	# 返回空字符串
	# 我们之前在 ability_data 里写过过滤逻辑，空字符串会被自动忽略
	return ""
