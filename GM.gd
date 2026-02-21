extends Node2D
class_name game_manager

#statemachine
@onready var gm_state_machine:Node = $GMStateMachine

@onready var son_node_group:Array = [$"unit spawner",$"enemy spawner",$Money_system]

#canvaslayer
@onready var cl = $CanvasLayer

#money system
@onready var ms = $Money_system

#hex system
@onready var hs = $hex_manager

#level system
@onready var ls = $level_manager
@onready var wave_number_label = $CanvasLayer/VBoxContainer/wave_number


func _ready() -> void:
	
	pass


func spawn_base(side_n):
	var new_unit = Global.minion_scene.instantiate()
	new_unit.ini_w_data(UnitAutoload.unit_dic["base"])
	new_unit.add_to_group("base_tower")
	
	new_unit.z_index = 3
	if side_n == "ally":
		new_unit.position = Vector2(115,425)
		new_unit.add_to_group("ally")
	else:
		new_unit.position = Vector2(1025,425)
		new_unit.add_to_group("enemy")
	new_unit.side = side_n
	add_child(new_unit)


func group_switch_func(b):
	for node in son_node_group:
		node.function_switch(b)

func clear_board():
	get_tree().call_group("unit", "queue_free")

func clear_board_by_group(group_n):
	get_tree().call_group(group_n, "queue_free")
