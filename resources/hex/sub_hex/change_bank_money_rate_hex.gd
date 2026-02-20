extends sub_hex_data
class_name change_bank_money_rate_hex

@export var X:float = 0

func hex_process(gm):
	gm.ms.income_multiplyer += X


func hex_process_take_back(gm):
	gm.ms.income_multiplyer = 1

func get_description() -> String:
	# 1. 组装基础句子
	var base_desc = "Gain " + str(X * 100) + "% more money from the bank"
	
	# 2. 根据 one_time 添加时间后缀
	if one_time:
		return base_desc + " for the next round only."
	else:
		return base_desc + " permanently."
