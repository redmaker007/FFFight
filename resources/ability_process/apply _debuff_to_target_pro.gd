extends ability_process
class_name apply_debuff_to_target_pro

@export var target:target_selector
@export var debuff:String


func process(m):
	for t in target.tar_select(m):
		t.apply_debuff(debuff)
	pass
