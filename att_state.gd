extends Node




func state_ready():

	
	pass


func state_process(delta: float) -> void:

	
	if get_parent().att_CD_sec <= 0:
		get_parent().attack_t()
		get_parent().att_CD_sec = get_parent().att_CD
	else:
		get_parent().att_CD_sec -=delta
	pass
