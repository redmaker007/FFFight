extends Resource
class_name minion_data

@export var minion_id:String

@export var minion_name:String

@export var cost:int
@export var deploy_cd: float

@export var speed:float
@export var max_hp:float
@export var att:float
@export var att_r:float
@export var att_spd:float



@export var image:Texture2D

@export var size:float
@export var ability:Array[ability_data]

func get_data_dic() -> Dictionary:
	var dict = {
		"unit_name" = minion_name,
		"speed" = speed,
		"max_hp" = max_hp,
		"att" = att,
		"att_r" = att_r,
		"att_spd" = att_spd,
		"image" = image,
		"deploy_cd" = deploy_cd,
		"size" = size,
		"ability" = ability,
		
	}
	
	return dict
	
