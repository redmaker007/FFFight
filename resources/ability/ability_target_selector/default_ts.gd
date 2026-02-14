extends target_selector
class_name default_ts

@export_group("AOE")
@export var aoe:bool = false
@export var aoe_range:float = 0.0
@export_enum("self","oppo") var side:int

func tar_select(mn=null,gm=null):
	if aoe and mn.target:
		return mn.target.get_range_unit(side,aoe_range)
	if mn.target:
		return [mn.target]
