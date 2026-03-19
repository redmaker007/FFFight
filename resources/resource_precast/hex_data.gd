extends Resource
class_name hex_data

@export var hex_name: String
@export var hex_id: String

@export_group("positive_effect")
@export var positive_hex_list: Array[sub_hex_data]


@export_group("negative_effect")
@export var negative_hex_list: Array[sub_hex_data]


@export_group("general")
@export_enum("D", "S", "A", "B", "C") var hex_rarity: String = "C"

func get_pos_des() -> String:
	var parts: Array[String] = []
	for sub in positive_hex_list:
		if sub and sub.has_method("get_description"):
			var desc = sub.get_description()
			if desc != "":
				parts.append(desc)
	if parts.size() == 0:
		return ""
	elif parts.size() == 1:
		return parts[0]
	else:
		return " ".join(parts.slice(0, parts.size() - 1)) + " " + tr("AND") + " " + parts[-1]

func get_neg_des() -> String:
	if negative_hex_list.is_empty():
		return tr("None")
	var parts: Array[String] = []
	for sub in negative_hex_list:
		if sub and sub.has_method("get_description"):
			var desc = sub.get_description()
			if desc != "":
				parts.append(desc)
	if parts.size() == 0:
		return ""
	elif parts.size() == 1:
		return parts[0]
	else:
		return " ".join(parts.slice(0, parts.size() - 1)) + " " + tr("AND") + " " + parts[-1]

func get_name_text() -> String:
	return tr(hex_id + "_NAME") #修改

func get_description() -> String:
	return ""
