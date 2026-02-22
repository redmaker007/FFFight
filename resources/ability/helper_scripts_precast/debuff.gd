extends Resource
class_name debuff

@export_group("基础")
@export var debuff_id:String
@export var stat_change:bool = false
@export var stat_str:String
@export var duration:float
@export var percentage_change:float = 1
@export var addition_change:float =0

@export_group("进阶")
@export var continue_harm_stat:float

func get_description() -> String:
	# 1. 名字美化 (比如 "armor_break" -> "Armor Break")
	var name_str = debuff_id.replace("_", " ").capitalize() if debuff_id != "" else "a debuff"
	
	var details = []
	
	# 2. 解析属性改变 (Stat Change)
	if stat_change and stat_str != "":
		var stat_name = stat_str.replace("_", " ").capitalize()
		var mods = []
		
		# 处理固定值加减 (例如 +10 或者 -5)
		if addition_change != 0:
			var sign_str = "+" if addition_change > 0 else ""
			mods.append(sign_str + str(addition_change))
			
		# 处理百分比加减 (例如 1.2 变成 +20%, 0.8 变成 -20%)
		if percentage_change != 1.0:
			# 将浮点数比例转换成直观的百分比
			var pct = (percentage_change - 1.0) * 100
			var sign_str = "+" if pct > 0 else ""
			mods.append(sign_str + str(pct) + "%")
			
		if not mods.is_empty():
			details.append(" ".join(mods) + " " + stat_name)
			
	# 3. 解析持续伤害 (DoT - Damage over Time)
	if continue_harm_stat > 0:
		details.append("dealing " + str(continue_harm_stat) + " continuous damage")
		
	# 4. 把细节用括号括起来 (如果有细节的话)
	var detail_str = ""
	if not details.is_empty():
		detail_str = " (" + ", ".join(details) + ")"
		
	# 5. 拼装最终结果："名字 (细节) 持续时间"
	var final_str = name_str + detail_str
	if duration > 0:
		final_str += " for " + str(duration) + "s"
		
	return final_str
