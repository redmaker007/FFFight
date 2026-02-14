extends ability_process
class_name due_X_damage_pro

@export var target:target_selector
@export var constant_damage_value:float = 0
@export var att_based_damage_value_ratio:float =0


func process(m):
	for t in target.tar_select(m):
		t.take_damage(t.get_moded_stat("att")*att_based_damage_value_ratio+constant_damage_value,m)
