extends Node



@export var spec_unit:String



var GM

var pool = ["red","blue","boxer","snow_ball_shooter"]
var u_name

var functioning

var spawn_CD = 0
var count = 0
var spawn_t_time = 1

func _ready() -> void:
	GM = get_parent()
	count = 0
	functioning = true



func function_switch(v:bool):
	functioning =v

func _process(delta: float) -> void:
	if not functioning:
		return
	if spawn_CD >= spawn_t_time:
		var ab = []
		ab = spawn_level_1()
		print(count)
		spawn_enemy_1(ab[0])
		spawn_t_time = ab[1]
		spawn_CD = 0
	else:
		spawn_CD += delta
	pass

func spawn_level_1():
	var unit_name
	var time_int
	if count < 4:
		unit_name = "red"
		time_int = 5

	elif count < 16:
		unit_name = "red"
		if count%2 ==0:
			time_int = 1
		else:
			time_int = 3
	elif count < 20:
		unit_name = "blue"
		time_int = 1
	elif count < 75:
		if count %10 == 0:
			unit_name = "snow_ball_shooter"
			time_int = 3
		else:
			unit_name = ["red","blue"].pick_random()
			time_int = 2
	elif count < 80:
		unit_name = "boxer"
		time_int = 0.1
	else:
		unit_name = pool.pick_random()
		time_int = 1
	
	
	count +=1
	return [unit_name,time_int]

func spawn_enemy_1(s_name):
	
	var new_enemy = GM.minion_precast.instantiate()

	new_enemy.ini_w_dic(GM.mm.mm[s_name])

	
	new_enemy.z_index = 3
	new_enemy.position = Vector2(1100,425)
	new_enemy.side = "enemy"
	new_enemy.add_to_group("unit")
	new_enemy.add_to_group("enemy")
	GM.add_child(new_enemy)
	
