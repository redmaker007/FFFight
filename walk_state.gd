extends Node

func state_ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.

func state_process(delta: float) -> void:
	if get_parent().side == "ally":
		get_parent().position.x +=get_parent().speed*delta
	else:
		get_parent().position.x -=get_parent().speed*delta
	pass
