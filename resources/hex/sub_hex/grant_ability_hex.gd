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

func get_description():
	
	var ab_name=""
	for a in ability_l:
		ab_name += a.ability_name+", "
	# 2. 获取目标描述
	var tar_desc = "Units"
	# 假设 target_selector 也有一个获取描述的方法
	if target_selec and target_selec.has_method("get_description"):
		tar_desc = target_selec.get_description()
	
	return tar_desc + " gain " + ab_name
