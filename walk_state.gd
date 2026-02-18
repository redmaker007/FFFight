extends Node

@onready var mn = get_parent()
func state_ready():
	
	if mn.unit_name == "boxer":
		mn.play_anim("walk",mn.get_moded_stat("speed")/50)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.

func state_process(delta: float) -> void:
	var calculated_speed
	
	calculated_speed = mn.get_moded_stat("speed")
	if mn.side == "ally":
		mn.position.x +=(calculated_speed)*delta
	else:
		mn.position.x -=(calculated_speed)*delta
	pass
