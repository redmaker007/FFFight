extends Node
#attack state
@onready var p = get_parent()

var _attack_triggered: bool = false

func state_ready():
	p.play_anim(p.unit_id + " idle", 1.0)
	_attack_triggered = false

func state_process(delta: float) -> void:
	if not p.target or p.target.is_dead:
		p.switch_state(p.state.walk)
		return
	
	if p.is_dead:
		return
	
	p.att_CD_sec -= delta
	
	var cd = 1.0 / max(p.get_moded_stat("att_spd"), 0.01)
	
	# 在3/4时间点播攻击动画
	if p.att_CD_sec <= cd * 0.25 and not _attack_triggered:
		_attack_triggered = true
		p.play_anim(p.unit_id + " attack", p.get_moded_stat("att_spd") * 4.0)
	
	# CD归零时造成伤害并重置
	if p.att_CD_sec <= 0:
		_attack_triggered = false
		p.attack_t()
		p.att_CD_sec = cd
		p.play_anim(p.unit_id + " idle", 1.0)
