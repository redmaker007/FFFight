extends sub_hex_data
class_name give_x_money_hex


@export var X_money:int


func hex_process(gm):
	
	gm.ms.get_fund(X_money)

func get_description() -> String:
	# 基础描述
	var base_desc = "gain " + str(X_money) + " money"
	
	# 根据 one_time 决定后缀
	if one_time:
		return base_desc + " for the next round only." # 或者直接写 " once." (一次性)
	else:
		return base_desc + " every round." # 如果不是一次性，通常意味着每回合都会给钱
