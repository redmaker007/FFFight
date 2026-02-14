extends sub_hex_data
class_name change_bank_money_rate_hex

@export var X:float = 0

func hex_process(gm):
	gm.ms.income_multiplyer += X


func hex_process_take_back(gm):
	gm.ms.income_multiplyer = 1

func get_description():
	return "Gain "+str(X*100)+"% more money from bank."
