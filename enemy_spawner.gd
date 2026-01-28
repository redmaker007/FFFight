extends Node


@export var random_pool_on:bool
@export var spec_unit:String



var GM
var spawn_CD = 0
var pool = ["red","blue","boxer","snow_ball_shooter"]
var u_name

var functioning


func _ready() -> void:
	GM = get_parent()
	function_switch(true)
	if not random_pool_on:
		u_name = spec_unit

func function_switch(v:bool):
	functioning =v

func _process(delta: float) -> void:
	if spawn_CD >= 1.5:
		if random_pool_on:
			u_name = pool.pick_random()
		spawn_enemy_1(u_name)
		spawn_CD = 0
	else:
		spawn_CD += delta
	pass




func spawn_enemy_1(s_name):
	if not functioning:
		return
	var new_enemy = GM.minion_precast.instantiate()

	new_enemy.ini_w_dic(GM.mm.mm[s_name])

	
	new_enemy.z_index = 3
	new_enemy.position = Vector2(1100,425)
	new_enemy.side = "enemy"
	new_enemy.add_to_group("unit")
	new_enemy.add_to_group("enemy")
	GM.add_child(new_enemy)
	
