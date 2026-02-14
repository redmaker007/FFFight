extends Node2D

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
	"att_CD" =1.0,
	}


var stat_mod_l ={
"speed"=[],
"hp" =[],
"max_hp" =[],
"att" =[],
"att_r" =[],
"att_CD" =[],
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
var att_CD_sec

#技能槽
var abilities = {}


#狀態機
enum state{walk,attack,pause}
var state_map = {}
var current_state = 0

#预引用
@onready var sprite = $Minion


func _ready() -> void:
	state_map = {
	0:$walk_state,
	1:$att_state,
	}
	await get_tree().process_frame
	if side == "enemy":
		$Minion.flip_h = true

	stat_dic["hp"] = stat_dic["max_hp"]

	switch_state(state.walk)
	position = self.position - Vector2(0,size*50)
	$health.value = 100
	if sprite.material:
		sprite.material = sprite.material.duplicate()





func _process(delta: float) -> void:
	if(state_map[current_state]):
		state_map[current_state].state_process(delta)
	if target == null and find_target():
		if abs(find_target().position.x - self.position.x) <= stat_dic["att_r"]:
			target = find_target()
			switch_state(state.attack)


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
			if side == "enemy":
				if t.position.x > max_x_target.position.x:
					max_x_target = t
			else:
				if t.position.x < max_x_target.position.x:
					max_x_target = t
	else:
		return null
	
	return max_x_target


func switch_state(st:state):
	match st:
		0:
			current_state = 0
		pass
		1:
			current_state = 1
	state_map[current_state].state_ready()
	pass

func set_png(png):
	$Minion.texture = png
	
	pass

func ini_w_data(data:minion_data):
	unit_name =data.minion_name
	

	
	#set_current_stat
	
	stat_dic["speed"] = data.speed
	stat_dic["hp"] = data.max_hp
	stat_dic["max_hp"] = data.max_hp
	stat_dic["att"] = data.att
	stat_dic["att_r"] = data.att_r
	stat_dic["att_CD"] = data.att_CD
	set_png(data.image)
	scale = Vector2(1,1)*(1+data.size)
	size = data.size
	att_CD_sec = stat_dic["att_CD"]
	set_abilities(data.ability)
	
	
	pass

func set_abilities(abilities_data):
	for a in abilities_data:
		var act_ab = active_ability.new()
		act_ab.ab_data = a
		act_ab.init()
		abilities[a.ability_name] = act_ab


func attack_t():
	#攻击时没有目标就回到走路state
	if not target:
		switch_state(state.walk)
		return
	#不然就造成伤害
	
	target.take_damage(get_moded_stat("att"))

	#尝试使用所有攻击时触发的技能
	for a in abilities:
		var act_ab = abilities[a].ab_data
		if act_ab.trigger == 0:
			act_ab.condition_then_process(self)
		pass
	
	#简易攻击动画 -之后改
	attack_animation()
	pass




func attack_animation():
	var side_sign
	var base_pos = $Minion.position
	if side == "ally":
		side_sign = 1
	else:
		side_sign = -1
	var tw = create_tween()
	tw.parallel().tween_property($Minion,"position",base_pos +Vector2(side_sign*10,0),0.1)
	tw.parallel().tween_property($Minion,"rotation_degrees",side_sign*20,0.1)
	
	tw.tween_property($Minion,"position",base_pos,0.05)
	tw.tween_property($Minion,"rotation_degrees",0,0.05)

func take_damage(value):
	print(value)
	play_hit_flash()
	stat_dic["hp"] -= value
	$health.value = float(get_moded_stat("hp"))/float(get_moded_stat("max_hp"))*100


	if ( get_moded_stat("hp") <= 0):
		death()

func refresh():
	$health.value = float(get_moded_stat("hp"))/float(get_moded_stat("max_hp"))*100



func death():
	SignalBus.emit_signal("unit_death",self)
	queue_free()

func apply_debuff(debf_re:debuff):
	$debuff_slot.get_debuffed(debf_re)
	pass

func play_hit_flash():
	# 确保材质是唯一的 (Resource是共享的，不加这就所有怪一起闪)
	# 注意：最好在 _ready 里做 duplicate，这里为了演示写在这里
	if sprite.material:
		# 1. 设置为纯白
		sprite.material.set_shader_parameter("flash_modifier", 0.5)
		
		# 2. 用 Tween 做一个快速的淡出动画 (0.1秒变回原色)
		var tween = create_tween()
		tween.tween_property(sprite.material, "shader_parameter/flash_modifier", 0.0, 0.1)

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
