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


func _get_base_description() -> String:
	# 1. 技能名称列表
	var ab_names: Array[String] = []
	for a in ability_l:
		if a and a.has_method("get_ability_name"):
			ab_names.append(a.get_ability_name())

	var ab_str = ", ".join(ab_names)

	# 2. 目标描述
	var tar_desc = tr("TARGET_UNITS")
	if target_selec and target_selec.has_method("get_description"):
		tar_desc = target_selec.get_description()

	# 3. 拼接
	var base_desc = tar_desc + " " + tr("ABILITY_GAIN") + " " + ab_str

	return base_desc
