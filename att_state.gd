extends Node

var  att_CD_sec

func state_ready():
	att_CD_sec = get_parent().att_CD
	pass


func state_process(delta: float) -> void:
	if att_CD_sec <= 0:
		get_parent().attack()
		att_CD_sec = get_parent().att_CD
	else:
		att_CD_sec -=delta
	pass
