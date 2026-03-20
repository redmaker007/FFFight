extends Node2D
class_name game_manager

#region 1. 核心組件與子系統 (Core Systems)
@onready var gm_state_machine: Node = $GMStateMachine
@onready var hs = $hex_manager      # Hex 系統
@onready var ms = $Money_system     # 經濟系統
@onready var ls = $level_manager    # 關卡數據管理
@onready var es = $"enemy spawner"  # 敵人生成器
@onready var us = $"unit spawner"   # 玩家單位生成器

# 用於 group_switch_func 的子節點清單
@onready var son_node_group: Array = [us, es, ms]
#endregion

#region 2. UI 引用 (UI Elements)
@export_group("UI Containers")
@onready var cl = $CanvasLayer
@onready var spawn_button_container = $CanvasLayer/HUD_Root/SpawnPanel/HBoxContainer
@onready var result_screen = $CanvasLayer/HUD_Root/ResultScreen

@export_group("Status Display")
@onready var wave_number_label = $CanvasLayer/HUD_Root/TopBar_BG/TopBar/waveSegment/VBoxContainer/wave_number
@onready var ally_hp_bar = $CanvasLayer/HUD_Root/TopBar_BG/TopBar/AllyHPBarBG/AllyHPBar/ally_hp_bar
@onready var ally_hp_text = $CanvasLayer/HUD_Root/TopBar_BG/TopBar/AllyHPBarBG/AllyHPBar/HPLabel/ally_hp_text
@onready var enemy_hp_bar = $CanvasLayer/HUD_Root/TopBar_BG/TopBar/EnemyHPBarBG/EnemyHPBar/enemy_hp_bar
@onready var enemy_hp_text = $CanvasLayer/HUD_Root/TopBar_BG/TopBar/EnemyHPBarBG/EnemyHPBar/HPLabel/enemy_hp_text
#endregion

#region 3. 初始化與信號 (Lifecycle & Signals)
func _ready() -> void:
	SignalBus.base_hp_changed.connect(_on_base_hp_changed)

func _on_base_hp_changed(side: String, current_hp: float, max_hp: float):
	var pct = (current_hp / max_hp) * 100
	# 格式化數字通常不需要 tr()，但如果未來有 "HP: " 等前綴，則需要
	var hp_display_text = str(snapped(current_hp, 1)) + " / " + str(snapped(max_hp, 1))
	
	if side == "ally":
		ally_hp_bar.value = pct
		ally_hp_text.text = hp_display_text
	else:
		enemy_hp_bar.value = pct
		enemy_hp_text.text = hp_display_text
#endregion

#region 4. 戰局流程控制 (Match Controls)
## 切換所有子系統的啟動/停止狀態 (戰鬥/準備切換)
func group_switch_func(b: bool):
	for node in son_node_group:
		if node.has_method("function_switch"):
			node.function_switch(b)

## 生成雙方基地塔
func spawn_base(side_n: String):
	# 注意：這裡的 "base" 是 Key，對應翻譯文件中的單位名稱
	var unit_data = UnitAutoload.unit_dic["base"]
	var new_unit = Global.minion_scene.instantiate()
	
	new_unit.ini_w_data(unit_data)
	new_unit.add_to_group("base_tower")
	new_unit.z_index = 3
	new_unit.side = side_n
	
	var hp_val = str(snapped(new_unit.get_moded_stat("hp"), 1))
	var max_hp_val = str(snapped(new_unit.get_moded_stat("max_hp"), 1))
	var hp_string = hp_val + " / " + max_hp_val
	
	if side_n == "ally":
		new_unit.position = Vector2(170, 735)
		new_unit.add_to_group("ally")
		new_unit.add_to_group("base")
		if ally_hp_text:
			ally_hp_text.text = hp_string
	else:
		new_unit.position = Vector2(1775, 735)
		new_unit.add_to_group("enemy")
		new_unit.add_to_group("base")
		if enemy_hp_text:
			enemy_hp_text.text = hp_string
	
	add_child(new_unit)

## 清除場上所有單位
func clear_board():
	get_tree().call_group("unit", "queue_free")

## 根據群組清除單位 (例如只清除 "enemy")
func clear_board_by_group(group_n: String):
	get_tree().call_group(group_n, "queue_free")

## 重置敵人生成計數
func em_reset_count():
	es.reset_whole()

## 重置 UI 血條顯示
func reset_top_bar():
	ally_hp_bar.value = 100
	enemy_hp_bar.value = 100

## 結算界面顯示
func show_result(win: bool):
	var current_wave = es.wave_count
	# 這裡建議將 win/loss 的標題判斷交給 result_screen 內部處理
	# 如果要在這裡處理，可以使用 tr("KEY_WIN") 或 tr("KEY_LOSE")
	result_screen.show_result(win, current_wave, ms.money_amount, 0)
#endregion

#region 5. 刷怪按鈕 CD 控制 (Spawn Buttons API)
## 模式定義：0 為覆蓋式 (Override), 1 為依據式/疊加式 (Add)
enum CD_MODIFY_MODE { OVERRIDE, ADD }

## 函數 1：修改全體按鈕的 CD
func modify_all_buttons_cd(mul: float, add: float, mode: int = CD_MODIFY_MODE.ADD):
	for btn in spawn_button_container.get_children():
		_apply_cd_to_btn(btn, mul, add, mode)

## 函數 2：修改特定按鈕的 CD (透過 unit_id 辨別)
func modify_unit_button_cd(target_id: String, mul: float, add: float, mode: int = CD_MODIFY_MODE.ADD):
	for btn in spawn_button_container.get_children():
		if "unit_id" in btn and btn.unit_id == target_id:
			_apply_cd_to_btn(btn, mul, add, mode)
			break

## 內部輔助函數：執行實際的方法調用
func _apply_cd_to_btn(btn: Node, mul: float, add: float, mode: int):
	if mode == CD_MODIFY_MODE.OVERRIDE:
		if btn.has_method("apply_cd_modifier"):
			btn.apply_cd_modifier(mul, add)
	else:
		if btn.has_method("add_cd_modifier"):
			btn.add_cd_modifier(mul, add)
func reset_all_buttons_cd():
	for btn in spawn_button_container.get_children():
		if btn.has_method("reset_cd"):
			btn.reset_cd()
#endregion
