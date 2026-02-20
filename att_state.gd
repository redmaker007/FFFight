extends Node

@onready var p = get_parent()


func state_ready():
	if p.unit_name == "boxer":
		p.attack_animation()
	
	pass


func state_process(delta: float) -> void:
	
	if not p.target or p.target.is_dead:
		p.switch_state(p.state.walk)
	# 为了代码整洁，建议把 get_parent() 存个变量，不然调用太频繁了
	if p.is_dead:
		return
	
	if p.att_CD_sec <= 0:
		
		# 1. 执行攻击
		p.attack_t()
		
		# === 核心修改 ===
		# 获取经过 Buff 计算后的最终攻速 (比如 2.0)
		# 注意：一定要用 get_moded_stat，否则你的 Buff 加成无效！
		var final_spd = p.get_moded_stat("att_spd")
		
		# 防御性编程：防止攻速被减成 0 或负数导致除以零报错
		if final_spd <= 0.01:
			p.att_CD_sec = 999.0 # 攻速太慢，设为一个极大值
		else:
			# 公式：冷却时间 = 1 / 频率
			# 攻速 2.0 -> 冷却 0.5秒
			# 攻速 0.5 -> 冷却 2.0秒
			p.att_CD_sec = 1.0 / final_spd
			
	else:
		p.att_CD_sec -= delta
	pass
