extends sub_hex_data
class_name give_x_money_hex


@export var X_money:int


func hex_process(gm):
	
	gm.ms.get_fund(X_money)

func _get_base_description() -> String:
	var base_desc = tr("MONEY_GAIN") + " $" + str(X_money)

	if one_time:
		return base_desc + " (" + tr("EFFECT_ONE_TIME") + ")"
	else:
		return base_desc + " (" + tr("MONEY_EVERY_ROUND") + ")"
