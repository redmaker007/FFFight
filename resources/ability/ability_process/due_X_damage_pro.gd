extends ability_process
class_name due_X_damage_pro

@export var target:target_selector
@export var constant_damage_value:float = 0
@export var att_based_damage_value_ratio:float =0


func process(m):
	# 防御性编程：防空指针
	if target == null:
		return
		
	# 💡 修复：伤害应该基于施法者 m 的攻击力，并且提出来算一次就够了，不用在 for 循环里反复算
	var total_damage = constant_damage_value
	if att_based_damage_value_ratio > 0 and m.has_method("get_moded_stat"):
		total_damage += m.get_moded_stat("att") * att_based_damage_value_ratio
		
	# 对所有选中的目标造成伤害
	for t in target.tar_select(m):
		if t.has_method("take_damage"):
			t.take_damage(total_damage, m)

func get_description() -> String:
	# 1. 组装伤害数值文案
	var dmg_parts = []
	if constant_damage_value > 0:
		dmg_parts.append(str(constant_damage_value))
	if att_based_damage_value_ratio > 0:
		# 把 1.5 转换成 "150% of Attack"
		dmg_parts.append(str(att_based_damage_value_ratio * 100) + "% of Attack")
		
	var dmg_text = "0"
	if not dmg_parts.is_empty():
		# 如果既有固定伤害又有加成，就会拼成 "50 + 100% of Attack"
		dmg_text = " + ".join(dmg_parts)
		
	# 2. 获取目标文案
	var target_text = "a target"
	if target and target.has_method("get_description"):
		var t_desc = target.get_description()
		if t_desc != "":
			target_text = t_desc
			
	# 3. 完美拼装
	return "deal " + dmg_text + " damage to " + target_text
