extends Node

var current_debuff_dict= {}

@onready var dm =$"../debuff_map"
@onready var mn = get_parent()

var sec =0



func get_debuffed(debf_re,tar):
	if (is_debuffed(debf_re.debuff_id)):
		var d = current_debuff_dict[debf_re.debuff_id][0]
		d.time_left = d.data.duration
	else:
		var ad = active_debuff.new()
		ad.data = debf_re
		ad.start(mn)
		current_debuff_dict[debf_re.debuff_id] = [ad,tar]


func is_debuffed(debf_id):
	if current_debuff_dict.has(debf_id):
		return true
	return false

func _process(delta: float) -> void:
	
	if current_debuff_dict.is_empty():
		return
	var temp_l = []
	for i in current_debuff_dict:
		var act_d = current_debuff_dict[i]
		act_d[0].time_left -= delta
		if act_d[0].data.continue_harm_stat:
			if sec >= 0.5:
				mn.take_damage(act_d[0].data.continue_harm_stat*0.5,act_d[1],0.1)
				sec = 0
			else:
				sec += delta
		if act_d[0].time_left <= 0:
			temp_l.append(i)
	for i in temp_l:
		current_debuff_dict[i][0].end(mn)
		current_debuff_dict.erase(i)
