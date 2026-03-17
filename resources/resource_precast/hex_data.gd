extends Resource
class_name hex_data

@export var hex_name: String
@export var hex_id: String

@export_group("positive_effect")
@export var positive_hex_list: Array[sub_hex_data]


@export_group("negative_effect")
@export var negative_hex_list: Array[sub_hex_data]


@export_group("general")
@export var neg_has_text: bool = true #修改：如果某些卡沒有負面描述可控制
@export_enum("D", "S", "A", "B", "C") var hex_rarity: String = "C"

func get_pos_des() -> String:
	return tr(hex_id + "_POS") #修改

func get_neg_des() -> String:
	if not neg_has_text:
		return tr("None")
	return tr(hex_id + "_NEG") #修改

func get_name_text() -> String:
	return tr(hex_id + "_NAME") #修改

func get_description() -> String:
	return ""
