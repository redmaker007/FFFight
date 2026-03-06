extends sub_hex_data
class_name give_target_stat

@export var stat_str:String
@export var percentage_change:float =0
@export var addition_change:float =0

@export var target_selec:target_selector

func get_description() -> String:
	# 1. 获取目标描述
	var tar_desc = "Target"
	if target_selec and target_selec.has_method("get_description"):
		tar_desc = target_selec.get_description()
		
	# 2. 智能拼接数值变化 (去掉为 0 的部分)
	var changes = []
	if percentage_change != 0:
		# 如果是正数，加个 "+" 号更好看
		var sign = "+" if percentage_change > 0 else ""
		changes.append(sign + str(percentage_change * 100) + "%")
		
	if addition_change != 0:
		var sign = "+" if addition_change > 0 else ""
		changes.append(sign + str(addition_change))
		
	# 防御性检查：如果什么都没填
	if changes.is_empty():
		return "No stat changes."
		
	var change_str = " and ".join(changes) # 拼成 "+10%" 或 "+10% and +5"
	
	# 3. 美化属性名字 (例如: "max_hp" -> "Max Hp", "att" -> "Att")
	var nice_stat_name = stat_str.replace("_", " ").capitalize()
	
	# 4. 组装前半句: "[谁] 获得 [多少] 的 [什么属性]"
	var base_desc = tar_desc + " gain " + change_str + " " + nice_stat_name
	
	# 5. 加上你的时间后缀
	if one_time:
		return base_desc + " for the next round only."
	else:
		return base_desc + " permanently."

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
