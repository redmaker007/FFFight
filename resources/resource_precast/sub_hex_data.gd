extends Resource
class_name sub_hex_data

@export var one_time: bool = true

# 子类重写这个，不要重写 get_description
func _get_base_description() -> String:
	return ""

# 基类自动加后缀，子类不用动
func get_description() -> String:
	var base = _get_base_description()
	if base == "":
		return ""
	if one_time:
		return base + " (" + tr("EFFECT_ONE_TIME") + ")"
	else:
		return base + " (" + tr("EFFECT_PERMANENT") + ")"
