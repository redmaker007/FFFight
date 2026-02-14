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
	# 1. 基础伤害描述 (百分比)
	var desc = "deal " + str(multiply_att * 100) + "% ATK"
	
	# 2. 如果有固定伤害加成，才显示 "+ X"
	if addition_att > 0:
		desc += " + " + str(addition_att)
	
	desc += " damage to "
	
	# 3. 目标描述 (直接调用 target 刚刚写好的逻辑)
	# 这是一个多态调用：不管它是 self_ts 还是 default_ts，都能返回正确的文本
	if target:
		desc += target.get_description()
	else:
		desc += "target"
	
	# 4. Debuff 描述
	if not debuff_l.is_empty():
		desc += " and applies "
		var d_names = []
		for d in debuff_l:
			# 这里用了一个安全检查：
			# 如果你的 debuff 脚本里有个变量叫 name 或 debuff_name，就用它
			# 如果都没有，就用 Godot 资源自带的文件名 (resource_name)
			if "debuff_name" in d:
				d_names.append(d.debuff_name)
			elif "name" in d:
				d_names.append(d.name)
			else:
				# Godot Resource 默认都有这个属性 (在 Inspector 顶部的 Name)
				d_names.append(d.resource_name) 
		
		desc += ", ".join(d_names) # 把数组变成 "Burn, Slow" 这样的字符串
		
	return desc + "."
