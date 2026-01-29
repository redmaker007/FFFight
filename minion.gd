extends Node2D

#私人參數
var speed = 100
var hp = 100
var max_hp = 100
var att = 10
var att_r = 50
var att_CD = 1

#機制參數
var target = null
var side = "ally"
var size = 1
var unit_name
var att_CD_sec

#狀態機
enum state{walk,attack}
var state_map = {}
var current_state



func _ready() -> void:
	await get_tree().process_frame
	if side == "enemy":
		$Minion.flip_h = true

	hp = max_hp
	state_map = {
	0:$walk_state,
	1:$att_state
	}
	switch_state(state.walk)
	position = self.position - Vector2(0,size*50)
	$health.value = 100




func _process(delta: float) -> void:
	if(state_map[current_state]):
		state_map[current_state].state_process(delta)
	if target == null and find_target():
		if abs(find_target().position.x - self.position.x) <= att_r:
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

func ini_w_dic(dic):
	unit_name = dic["name"]
	speed = dic["speed"]
	hp = dic["max_hp"]
	max_hp = dic["max_hp"]
	att = dic["att"]
	att_r = dic["att_r"]
	att_CD = dic["att_CD"]
	set_png(dic["image"])
	scale = Vector2(1,1)*(1+dic["size"])
	size = dic["size"]
	att_CD_sec = att_CD
	pass


func attack_t():
	if not target:
		switch_state(state.walk)
		return
	target.take_damage(att)
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
	hp -= value
	$health.value = float(hp)/float(max_hp)*100
	if (hp <= 0):
		death()

func death():
	SignalBus.emit_signal("unit_death",self)
	queue_free()
