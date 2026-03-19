extends sub_hex_data
class_name give_target_stat

@export var stat_str:String
@export var percentage_change:float =0
@export var addition_change:float =0

@export var target_selec:target_selector

func _get_base_description() -> String:
	# 1. 目标描述
	var tar_desc = tr("TARGET_DEFAULT")
	if target_selec and target_selec.has_method("get_description"):
		tar_desc = target_selec.get_description()

	# 2. 数值变化
	var changes: Array[String] = []
	if percentage_change != 0:
		var sign = "+" if percentage_change > 0 else ""
		changes.append(sign + str(percentage_change * 100) + "%")
	if addition_change != 0:
		var sign = "+" if addition_change > 0 else ""
		changes.append(sign + str(addition_change))

	if changes.is_empty():
		return tr("STAT_NO_CHANGE")

	var change_str = " ".join(changes)

	# 3. 属性名用翻译key，找不到就fallback到原字符串
	var stat_key = "STAT_" + stat_str.to_upper()
	var nice_stat_name = tr(stat_key)

	# 4. 组装
	var base_desc = tar_desc + " " + tr("STAT_GAIN") + " " + change_str + " " + nice_stat_name

	return base_desc

func on_unit_spawn(m):
	if not m or not target_selec:
		return
	var tar = target_selec.tar_select(m)
	if m in tar:
		if percentage_change:
			m.add_mod(stat_str,percentage_change,false)
		if addition_change:
			m.add_mod(stat_str,addition_change,true)
	pass
