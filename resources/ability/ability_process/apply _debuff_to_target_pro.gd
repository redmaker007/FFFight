extends ability_process
class_name apply_debuff_to_target_pro

@export var target:target_selector
@export var _debuff:debuff


func process(m):
	for t in target.tar_select(m):
		t.apply_debuff(_debuff,m)
	pass

func get_description() -> String:
	# 1. 解析 Debuff 的名字和持续时间
	var debuff_text = "a debuff"
	if _debuff:
		# 假设你的 debuff 名字存在 debuff_id 里，把下划线换成空格美化一下
		var d_name = _debuff.debuff_id.replace("_", " ") if _debuff.debuff_id else "a stat change"
		debuff_text = d_name + " for " + str(_debuff.duration) + "s"
		
	# 2. 解析 Target (目标选择器) 的描述
	var target_text = "a target"
	if target and target.has_method("get_description"):
		var t_desc = target.get_description()
		if t_desc != "":
			target_text = t_desc
			
	# 3. 完美拼装："apply [debuff_text] to [target_text]"
	return "apply " + debuff_text + " to " + target_text
