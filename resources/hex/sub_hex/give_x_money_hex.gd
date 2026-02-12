extends sub_hex_data
class_name give_x_money_hex


@export var X_money:int


func hex_process(gm):
	
	gm.ms.get_fund(X_money)

func get_description():
	return "gain "+str(X_money)+" money one time."
