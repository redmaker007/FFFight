extends Resource
class_name ability_data

@export var ability_id:String

@export var ability_name:String

enum trigger_way{on_attack,death,X_times,get_hit,get_damage}

@export var trigger:trigger_way
	
@export var cons:Array[ability_condition]
@export var pro:ability_process


func condition_then_process(minion:Node2D):
	for c in cons:
		if not(c.condition(minion)):
			return
		pro.process(minion)

func init_ability(act_ability):
	for c in cons:
		c.init(act_ability)
