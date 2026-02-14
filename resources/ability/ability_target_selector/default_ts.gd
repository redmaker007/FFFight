extends target_selector
class_name default_ts

@export_group("AOE")
@export var aoe:bool = false
@export var aoe_range:float = 0.0
@export var aoe_central_target:target_selector
@export_enum("self","oppo") var side:int

func tar_select(mn=null,gm=null):
	
	if aoe:
		var tar_l =[]
		for t in aoe_central_target.tar_select(mn):
			for t1 in t.get_range_unit(side,aoe_range):
				tar_l.append(t1)
		return tar_l
	if mn.target:
		return [mn.target]

func get_description() -> String:
	# 1. 非 AOE 模式：简单直接
	if not aoe:
		return "current target"
	
	# 2. AOE 模式：需要拼接复杂的句子
	
	# A. 获取中心点的描述 (递归调用中心选择器的描述)
	var center_desc = "target"
	if aoe_central_target:
		# 这是一个防御性检查，确保那个变量有 get_description 方法
		if aoe_central_target.has_method("get_description"):
			center_desc = aoe_central_target.get_description()
	
	# B. 确定我们要找的是中心点的"盟友"还是"敌人"
	# side: 0 = self (同阵营), 1 = oppo (敌对阵营)
	var who = "units"
	match side:
		0: who = "allies"   # 比如：治疗波，选目标周围的盟友
		1: who = "enemies"  # 比如：爆炸，选目标周围的敌人
	
	# C. 拼接："[Who] within [Range] range of [Center]"
	return "%s within %s range of %s" % [who, str(aoe_range), center_desc]
