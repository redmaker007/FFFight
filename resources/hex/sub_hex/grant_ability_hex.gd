extends sub_hex_data
class_name grant_ability_hex

@export var ability_l:Array[ability_data]


@export var target_selec:target_selector


func on_unit_spawn(m):
	var tar = target_selec.tar_select(m)
	for t in tar:
		for abd in ability_l:
			t.add_ability(abd)
		pass


func get_description() -> String:
	# 1. 优雅地获取技能名称列表 (解决多余逗号的问题)
	var ab_names = []
	for a in ability_l:
		if a and "ability_name" in a:
			ab_names.append(a.ability_name)
	
	var ab_str = ", ".join(ab_names) # 这样会自动拼接成 "A, B, C" 格式
	
	# 2. 获取目标描述
	var tar_desc = "Units"
	if target_selec and target_selec.has_method("get_description"):
		tar_desc = target_selec.get_description()
	
	# 3. 拼接基础句子
	var final_desc = tar_desc + " gain " + ab_str
	
	# 4. 根据 one_time 追加持续时间描述
	if one_time:
		final_desc += " for the next round only."
	else:
		final_desc += " permanently." # 如果是永久的，加上这个词会让玩家更明确
		
	return final_desc
