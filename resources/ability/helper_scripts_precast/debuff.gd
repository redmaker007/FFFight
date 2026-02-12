extends Resource
class_name debuff

@export_group("基础")
@export var debuff_id:String
@export var stat_str:String
@export var duration:float
@export var percentage_change:float = 1
@export var addition_change:float =0

@export_group("进阶")
@export var continue_harm_stat:float
