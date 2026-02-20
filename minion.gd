extends Node2D

#region 1. 属性与数据 (Stats & Data) ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# 负责管理角色的数值、修饰器 (Buff) 和基础信息
# ------------------------------------------------------------------------------

#私人參數
#var speed :float= 100
#var hp :float= 100	
#var max_hp :float= 100
#var att :float= 10
#var att_r :float= 50
#var att_CD :float= 1

var stat_dic ={
	"speed"= 100.0,
	"hp" =100.0,
	"max_hp" =100.0,
	"att" =10.0,
	"att_r" =50.0,
	"att_spd" =1.0,
	}


var stat_mod_l ={
"speed"=[],
"hp" =[],
"max_hp" =[],
"att" =[],
"att_r" =[],
"att_spd" =[],
}

#get_stat 用来获得运算过后的数值
func get_moded_stat(stat_str):
	var calculated_value = stat_dic[stat_str]
	for m in stat_mod_l[stat_str]:
		if m.aom:
			calculated_value = m.mod(calculated_value)
	for m in stat_mod_l[stat_str]:
		if !m.aom:
			calculated_value = m.mod(calculated_value)
	return calculated_value

func add_mod(stat_str,value,aom):
	var mod = stat_mod.new()
	mod.aom =aom
	mod.stat = value
	stat_mod_l[stat_str].append(mod)
	return mod




#機制參數
var target = null
var side = "ally"
var size = 1
var unit_name
var unit_id
var att_CD_sec
var target_scan_timer: float = 0.0
var scan_interval: float = 0.06 # 0.2秒索敌一次 (也就是每秒5次)
var is_dead:bool = false

func ini_w_data(data:minion_data):
	unit_name =data.minion_name
	

	
	#set_current_stat
	
	stat_dic["speed"] = data.speed
	stat_dic["hp"] = data.max_hp
	stat_dic["max_hp"] = data.max_hp
	stat_dic["att"] = data.att
	stat_dic["att_r"] = data.att_r
	stat_dic["att_spd"] = data.att_spd
	set_png(data.image)
	scale = Vector2(1,1)*(1+data.size)
	size = data.size
	att_CD_sec = 0
	set_abilities(data.ability)
	
	unit_id = data.minion_id
	
	pass

#技能槽
var abilities = {}

func add_ability(abd:ability_data):
	var act_ab = active_ability.new()
	act_ab.ab_data = abd
	act_ab.init()
	abilities[abd.ability_name] = act_ab

func set_abilities(abilities_data):
	for a in abilities_data:
		add_ability(a)
#endregion

#region 2.状态机与逻辑流 (State Machine)------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# 负责状态切换和每帧逻辑更新
# ------------------------------------------------------------------------------

#狀態機
enum state{walk,attack,pause}
var state_map = {}
var current_state = 0

func switch_state(st:state):
	match st:
		0:
			current_state = 0
		pass
		1:
			current_state = 1
	state_map[current_state].state_ready()
	pass

# 寻找目标 (索敌逻辑)
func find_target():
	var target_group

	var max_x_target = null
	if (side == "ally"):
		target_group = "enemy"

	else:
		target_group = "ally"


		pass
	if get_tree().get_first_node_in_group(target_group):
		max_x_target= get_tree().get_first_node_in_group(target_group)
		for t in get_tree().get_nodes_in_group(target_group):
			if t.is_dead:
				break
			if side == "enemy":
				if t.position.x > max_x_target.position.x:
					max_x_target = t
			else:
				if t.position.x < max_x_target.position.x:
					max_x_target = t
	else:
		return null
	
	return max_x_target

# 获取自身范围内的单位
func get_range_unit(t_side=0,dis:float = 0):
	var o_side
	if t_side == 0:
		o_side = self.side
	else:
		if self.side == "ally":
			o_side = "enemy"
		else:
			o_side = "ally"
	
	var targets = get_tree().get_nodes_in_group(o_side)
	var results =[]
	for t in targets:
		if abs(t.position.x - self.position.x) <= dis:
			results.append(t)
			pass
	return results
#endregion

#region 3. 视觉与表现 (Visuals)------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# 负责动画、特效、Sprite 设置
# ------------------------------------------------------------------------------
#预引用
@onready var sprite = $Minion
@onready var anim_sprite = $AnimatedSprite2D

func set_png(png):
	$Minion.texture = png
	
	pass

func play_hit_flash(t):
	# 确保材质是唯一的 (Resource是共享的，不加这就所有怪一起闪)
	# 注意：最好在 _ready 里做 duplicate，这里为了演示写在这里
	if anim_sprite.material:
		# 1. 设置为纯白
		anim_sprite.material.set_shader_parameter("flash_modifier", 0.5)
		
		# 2. 用 Tween 做一个快速的淡出动画 (0.1秒变回原色)
		var tween = create_tween()
		tween.tween_property(anim_sprite.material, "shader_parameter/flash_modifier", 0.0, t)


func attack_animation():
	if is_dead:
		return

	play_anim(unit_id+" "+"attack",get_moded_stat("att_spd"))

func death_animation():
	var imag
	if anim_sprite.visible == true:
		imag = anim_sprite
	else:
		imag = sprite
	$health.visible = false
	# 视觉层级调整 (让尸体跳到最前面，不要被地板遮住)
	z_index = 100
	# 🎲 1. 随机决定方向 (左还是右)
	# randf() > 0.5 返回 1 (右)，否则返回 -1 (左)
	var dir = 1 if randf() > 0.5 else -1
	
	# 📏 定义跳跃力度
	var jump_height = 150.0  # 跳多高
	var side_dist = 100.0    # 横向飞多远 (总距离)
	var jump_time = 0.35
	
	var tw = create_tween()
	
	# ==============================
	# 阶段 A：起跳 (上升 + 往斜上方飞)
	# ==============================
	tw.set_parallel(true) # 让下面的动作同时发生
	
	# 1. Y轴：向上跳 (模拟重力减速：Ease Out)
	tw.tween_property(imag, "position:y", -jump_height, jump_time).as_relative().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# 2. X轴：横向移动总距离的 40% (线性移动，模拟惯性)
	tw.tween_property(imag, "position:x", side_dist * 0.4 * dir, jump_time).as_relative().set_trans(Tween.TRANS_LINEAR)
	
	# 3. 旋转：开始疯狂旋转
	tw.tween_property(imag, "rotation_degrees", 360.0 * dir, jump_time).as_relative()
	
	
	# ==============================
	# 阶段 B：下坠 (下落 + 继续往侧面飞)
	# ==============================
	# 🔗 .chain() 的作用是：必须等上面所有 parallel 的动画都播完了，才执行下面的
	tw.set_parallel(false)
	tw.tween_interval(jump_time)
	tw.set_parallel(true)
	# 1. Y轴：掉出屏幕 (模拟重力加速：Ease In)
	tw.tween_property(imag, "position:y", 1000.0, 0.5).as_relative().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	# 2. X轴：继续横向移动剩下的 60% (保持线性，让弧线圆润)
	tw.tween_property(imag, "position:x", side_dist * 0.6 * dir, 0.5).as_relative().set_trans(Tween.TRANS_LINEAR)
	
	# 3. 旋转：继续旋转 (防止空中停转)
	tw.tween_property(imag, "rotation_degrees", 360.0 * dir, 0.5).as_relative()
	
	
	
	
	await tw.finished
	pass
func refresh():
	$health.value = float(get_moded_stat("hp"))/float(get_moded_stat("max_hp"))*100
	
	$AnimatedSprite2D.visible = true
	$Minion.visible = false

func play_anim(anim_name,speed):
	
	if $AnimatedSprite2D.animation != anim_name:
		$AnimatedSprite2D.speed_scale = speed
		$AnimatedSprite2D.play(anim_name)

#endregion

#region 4. 战斗核心 (Combat)
# ------------------------------------------------------------------------------
# 负责造成伤害、承受伤害、死亡、技能触发
# ------------------------------------------------------------------------------


func attack_t():
	#攻击时没有目标就回到走路state
	if not target or target.is_dead:

		switch_state(state.walk)
		return
	#不然就造成伤害
	
	target.take_damage(get_moded_stat("att"),self)
	
	#尝试使用所有攻击时触发的技能
	for a in abilities:
		var act_ab = abilities[a]
		if act_ab.ab_data.trigger == 0:
			act_ab.use_ability(self)
	attack_animation()


func take_damage(value,tar,time =0.1):
	if is_dead:
		return
	play_hit_flash(time)
	stat_dic["hp"] -= value
	$health.value = float(get_moded_stat("hp"))/float(get_moded_stat("max_hp"))*100
	if ( get_moded_stat("hp") <= 0):
		is_dead = true
		death()

func death():
	
	is_dead = true
	if is_in_group("ally"): remove_from_group("ally")
	if is_in_group("enemy"): remove_from_group("enemy")
	if is_in_group("unit"): remove_from_group("unit")
	
	SignalBus.emit_signal("unit_death",self)
	#尝试使用所有死亡时触发的技能
	for a in abilities:
		var act_ab = abilities[a]
		if act_ab.ab_data.trigger == 1:
			act_ab.use_ability(self)
		pass
	
	await death_animation()
	queue_free()

func apply_debuff(debf_re:debuff,tar):
	$debuff_slot.get_debuffed(debf_re,tar)
	pass


#endregion

#region 5. 引擎回调 (Engine Callbacks)
# ------------------------------------------------------------------------------
# Godot 引擎生命周期函数
# ------------------------------------------------------------------------------
func _ready() -> void:
	
	state_map = {
	0:$walk_state,
	1:$att_state,
	}
	# 等待一帧是为了确保某些初始化完成
	await get_tree().process_frame
	
	if side == "enemy":
		$Minion.flip_h = true
		$AnimatedSprite2D.flip_h = true

	stat_dic["hp"] = stat_dic["max_hp"]

	switch_state(state.walk)
	# 调整位置和UI
	
	position = self.position - Vector2(0,size*50)
	$health.value = 100
	if anim_sprite.material:
		anim_sprite.material = anim_sprite.material.duplicate()





func _process(delta: float) -> void:
	if(state_map[current_state]):
		state_map[current_state].state_process(delta)
	if (target == null or target.is_dead) and current_state == 0:
		# 倒计时
		target_scan_timer -= delta
		if target_scan_timer <= 0:
			target_scan_timer = scan_interval + randf_range(-0.05, 0.02)
			var found = find_target()
			
			if found:
		# 只有距离够近才切换攻击状态
				if abs(found.position.x - self.position.x) <= stat_dic["att_r"]:
					target = found
					switch_state(state.attack)

#endregion
