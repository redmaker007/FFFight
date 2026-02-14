extends target_selector
class_name all_unit_type_ts

enum side{ally,enemy,all}
@export_group("筛选参数")
@export var pick_side:side
@export var unit_id:String = ""


func tar_select(mn=null,gm=null):
	var m
	if gm:
		m = gm
	elif mn:
		m = mn
	var temp_l_a =[]
	var temp_l_b =[]
	if pick_side !=  2:
		if pick_side == 0:
			temp_l_a = m.get_tree().get_nodes_in_group("ally")
		else:
			temp_l_a = m.get_tree().get_nodes_in_group("enemy")
	else:
		temp_l_a = m.get_tree().get_nodes_in_group("unit")
	if unit_id !="":
		for u in temp_l_a:
			if u.id == unit_id:
				temp_l_b.append(u)
		return temp_l_b
	else:
		return temp_l_a


func get_description() -> String:
	# 1. 确定我们要称呼"谁"
	# 如果指定了 unit_id (例如 "Archer")，就用它；否则统称为 "units"
	var target_name = "units"
	if unit_id != "":
		# capitalize() 会把 "archer" 变成 "Archer"，看起来更像名字
		target_name = unit_id.capitalize() + "s" # 加个s表示复数，如果不喜欢可以去掉
	
	# 2. 根据阵营拼接前缀
	var prefix = ""
	match pick_side:
		side.ally:
			if unit_id == "": # 特殊处理: "all allies" 比 "all friendly units" 更简短自然
				return "all allies"
			prefix = "all friendly "
		side.enemy:
			if unit_id == "":
				return "all enemies"
			prefix = "all enemy "
		side.all:
			prefix = "all "
	
	return prefix + target_name
