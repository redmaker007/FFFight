extends Node2D
class_name game_manager

#region description
#这段代码是你游戏中最顶层的“中央大脑”（Game Manager）。它本身并不负责处理具体的伤害计算或具体的 UI 动画，而是作为一个总调度中心，把游戏里各个独立的模块完美地捏合在一起。
#
#从整体架构来看，这个脚本承担了以下四个极其关键的宏观职能：
#
#1. 核心子系统的通讯枢纽 (System Hub)
#它通过 @onready 在游戏初始化时，牢牢抓取并掌管了游戏所有的命脉模块。
#你能看到它汇集了：状态机（GMStateMachine）、
#实体生成器（unit spawner 和 enemy spawner）、
#经济系统（Money_system）、蜂窝网格系统（hex_manager）、
#关卡与波次系统（level_manager）以及顶层 UI（CanvasLayer）。
#这种设计确立了 GM 作为最高权限节点的地位，方便后续进行跨模块调度。
#
#2. 游戏阶段的“总电闸” (Master Switch)
#group_switch_func 是一个非常实用且优雅的设计。
#配合着 GM 的状态机，这个函数允许你仅仅通过传入一个布尔值（true 或 false），
#就能瞬间同时开启或暂停玩家单位的生成、敌人的生成以及金币的自动增长。
#这显然是为了在“准备阶段 (Preparation)”、“战斗阶段 (Combat)”或“游戏结束 (Game Over)”之间进行干净利落的切换而准备的。
#
#3. 核心据点初始化 (Base Initialization)
#spawn_base 函数负责在战局最开始时“定海神针”。
#它会根据传入的阵营（ally 友军 或 enemy 敌军），
#在屏幕左右两端硬编码的固定坐标（左侧 X:115，右侧 X:1025）生成双方的主基地塔，
#并严谨地为它们分配了对应的 Group（节点组）和底层数据。
#
#4. 战局重置与快速清场 (Board Management)
#clear_board 和 clear_board_by_group 提供了极其高效的清场能力。
#利用 Godot 强大的 Group 特性，GM 不需要去遍历复杂的节点树，只需一声令下，就能在回合结束、重新开始或特殊机制触发时，
#瞬间清除全场所有单位或指定阵营的单位，确保下一波战斗干干净净地开始。
#endregion



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
@onready var wave_number_label = $CanvasLayer/HUD_Root/TopBar_BG/TopBar/waveSegment/VBoxContainer/wave_number

@onready var ally_hp_bar = $CanvasLayer/HUD_Root/TopBar_BG/TopBar/AllyHPBarBG/AllyHPBar/ally_hp_bar
@onready var ally_hp_text =$CanvasLayer/HUD_Root/TopBar_BG/TopBar/AllyHPBarBG/AllyHPBar/HPLabel/ally_hp_text
@onready var enemy_hp_bar = $CanvasLayer/HUD_Root/TopBar_BG/TopBar/EnemyHPBarBG/EnemyHPBar/enemy_hp_bar
@onready var enemy_hp_text = $CanvasLayer/HUD_Root/TopBar_BG/TopBar/EnemyHPBarBG/EnemyHPBar/HPLabel/enemy_hp_text

func _ready() -> void:
	SignalBus.base_hp_changed.connect(_on_base_hp_changed)
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

func _on_base_hp_changed(side: String, current_hp: float, max_hp: float):
	var pct = (current_hp / max_hp) * 100
	if side == "ally":
		ally_hp_bar.value = pct
		ally_hp_text.text = str(snapped(current_hp, 1)) + " / " + str(snapped(max_hp, 1))
	else:
		enemy_hp_bar.value = pct
		enemy_hp_text.text = str(snapped(current_hp, 1)) + " / " + str(snapped(max_hp, 1))
