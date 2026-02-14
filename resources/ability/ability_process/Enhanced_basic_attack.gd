extends ability_process
class_name enhanced_basic_attack

@export var target:target_selector
@export var debuff_l:Array[debuff]

@export var addition_att:float =0
@export var multiply_att:float = 1


func process(m):
	
	for t in target.tar_select(m):
		print(t.unit_name)
		for d in debuff_l:
			t.apply_debuff(d)
		t.take_damage(m.get_moded_stat("att")*multiply_att+addition_att)
	pass
