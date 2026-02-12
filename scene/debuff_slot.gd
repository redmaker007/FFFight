extends Node

var current_debuff_dict= {}

@onready var dm =$"../debuff_map"
@onready var mn = get_parent()



func get_debuffed(debf_re):
	if (is_debuffed(debf_re.debuff_id)):
		var d = current_debuff_dict[debf_re.debuff_id]
		d.time_left = d.data.duration
	else:
		var ad = active_debuff.new()
		ad.data = debf_re
		ad.start(mn)
		current_debuff_dict[debf_re.debuff_id] = ad


func is_debuffed(debf_id):
	if current_debuff_dict.has(debf_id):
		return true
	return false

func _process(delta: float) -> void:
	if current_debuff_dict.is_empty():
		return
	var temp_l = []
	for i in current_debuff_dict:
		current_debuff_dict[i].time_left -= delta
		if current_debuff_dict[i].time_left <= 0:
			temp_l.append(i)
	for i in temp_l:
		current_debuff_dict[i].end(mn)
		current_debuff_dict.erase(i)
