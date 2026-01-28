extends Node2D

#GameState
enum Gamestate{play_s,end_s}
var current_state
var state_map

@onready var son_node_group:Array = [$"unit spawner",$"enemy spawner"]
func switch_state(s:Gamestate):
	current_state = s
	state_map[current_state].enter_state()
	pass


#preload
var minion_precast = preload("res://minion_node.tscn")
var binion_png = preload("res://binion.png")
#unit data
@onready var mm:Node = $minion_map



func _ready() -> void:
	SignalBus.connect("unit_death",check_base_death)

	spawn_base("ally")
	spawn_base("enemy")
	state_map ={
		0:$play_state,
		1:$end_state
	}


func spawn_base(side_n):
	var new_unit = minion_precast.instantiate()
	new_unit.ini_w_dic(mm.mm["base"])
	
	new_unit.z_index = 3
	if side_n == "ally":
		new_unit.position = Vector2(115,425)
		new_unit.add_to_group("ally")
	else:
		new_unit.position = Vector2(1025,425)
		new_unit.add_to_group("enemy")
	new_unit.side = side_n
	add_child(new_unit)

func check_base_death(unit):
	if unit.unit_name == "base":
		if unit.side == "ally":
			print("you lose!")
		else:
			print("you win!")
		switch_state(Gamestate.end_s)
		
		
	else:
		return

func group_stop_func():
	for node in son_node_group:
		node.function_switch(false)

func clear_board():
	get_tree().call_group("unit", "queue_free")
