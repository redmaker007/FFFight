extends Resource
class_name hex_data

@export var hex_id:String
@export_group("positive_effect")
@export var positive_hex_list:Array[sub_hex_data]
@export_group("negative_effect")
@export var negative_hex_list:Array[sub_hex_data]

func get_pos_des():
	var text =""
	for i in positive_hex_list:
		text += i.get_description()+"\n"
	return text

func get_neg_des():
	var text =""
	for i in negative_hex_list:
		text += i.get_description()
	return text
