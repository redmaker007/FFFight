extends Resource
class_name ability_data

@export var ability_id:String

@export var ability_name:String

enum trigger_way{on_attack,death,X_times,get_hit,get_damage}

@export var trigger:trigger_way
	
@export var cons:Array[ability_condition]
@export var pro:ability_process


func condition_then_process(minion:Node2D,ref):
	for c in cons:
		if not(c.condition(minion,ref)):
			return
		pro.process(minion)

func init_ability(act_ability):
	for c in cons:
		c.init(act_ability)


func get_description() -> String:
	var desc_parts = []
	
	# 1. 解析 Trigger (触发器)
	var trigger_text = ""
	match trigger:
		trigger_way.on_attack: trigger_text = "On attack"
		trigger_way.death: trigger_text = "Upon death"
		trigger_way.X_times: trigger_text = "Every few attacks" # 具体X次可以根据需要扩展
		trigger_way.get_hit: trigger_text = "When hit"
		trigger_way.get_damage: trigger_text = "When taking damage"
	desc_parts.append(trigger_text)
	
	# 2. 解析 Conditions (条件)
	var con_texts = []
	for c in cons:
		if c and c.has_method("get_description"):
			var text = c.get_description()
			if text != "":
				con_texts.append(text)
	
	# 如果有条件，把它们用 " and " 连起来
	if not con_texts.is_empty():
		desc_parts.append("if " + " and ".join(con_texts))
		
	# 3. 解析 Process (结果/过程)
	if pro and pro.has_method("get_description"):
		desc_parts.append(pro.get_description())
	else:
		desc_parts.append("does something mysterious") # 防御性编程，防空指针
		
	# 4. 完美拼装
	# 用逗号和空格把这三部分连起来，并在句末加上句号
	var final_desc = ", ".join(desc_parts) + "."
	
	return final_desc
