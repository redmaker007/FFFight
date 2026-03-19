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
	# 1. 阵营描述
	var side_str: String
	match pick_side:
		side.ally:
			side_str = tr("TS_ALLY")
		side.enemy:
			side_str = tr("TS_ENEMY")
		side.all:
			side_str = tr("TS_ALL")

	# 2. 单位描述
	var unit_str: String
	if unit_id != "":
		unit_str = unit_id
	else:
		unit_str = tr("TS_UNITS")

	return side_str + " " + unit_str
