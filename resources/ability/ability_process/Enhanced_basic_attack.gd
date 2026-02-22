extends ability_process
class_name enhanced_basic_attack

@export var target:target_selector
@export var debuff_l:Array[debuff]

@export var addition_att:float =0
@export var multiply_att:float = 1


func process(m):
	
	for t in target.tar_select(m):
		
		for d in debuff_l:
			t.apply_debuff(d,m)
		t.take_damage(m.get_moded_stat("att")*multiply_att+addition_att,m)
	pass

func get_description() -> String:
	var desc = ""
	
	# 1. 🎯 精准拼接伤害部分 (屏蔽 0 的情况)
	var dmg_parts = []
	if multiply_att > 0:
		dmg_parts.append(str(multiply_att * 100) + "% ATK")
	if addition_att > 0:
		dmg_parts.append(str(addition_att))
		
	# 只有当真的有伤害时，才拼接 "deal ... damage to"
	if not dmg_parts.is_empty():
		desc += "deal " + " + ".join(dmg_parts) + " damage to "
	else:
		# 如果没有任何伤害，通常是纯辅助/控制技能
		desc += "target " 
	
	# 2. 🎯 拼接目标
	if target and target.has_method("get_description"):
		var t_desc = target.get_description()
		desc += t_desc if t_desc != "" else "target"
	else:
		desc += "target"
	
	# 3. 🎯 安全拼接 Debuff (防 null，且对接正确的变量名)
	var valid_debuff_names = []
	for d in debuff_l:
		# 必须确保这个槽位里真的放了 Resource，而不是空的
		if d != null:
			# 对接我们之前写的 debuff 类的 debuff_id 属性
			if "debuff_id" in d and d.debuff_id != "":
				valid_debuff_names.append(d.debuff_id.replace("_", " ").capitalize())
			else:
				valid_debuff_names.append("a debuff") # 终极退底保护
				
	# 只有提取到了真正有效的 debuff 名字，才拼上 "and applies"
	if not valid_debuff_names.is_empty():
		# 如果前面有伤害描述，就用 " and applies " 连起来
		# 如果前面没有伤害，就变成 "applies ... to target"
		if not dmg_parts.is_empty():
			desc += " and applies " + ", ".join(valid_debuff_names)
		else:
			# 替换掉前面的 "target " 逻辑，重组成更通顺的英语
			desc = "apply " + ", ".join(valid_debuff_names) + " to " + (target.get_description() if target else "target")
		
	return desc 
