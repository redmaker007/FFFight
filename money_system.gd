extends Node

#region 1. 公開參數 (Properties)
var default_money_amount = 100
var default_bank_level = 1

# --- 新增：等級上限鎖定 ---
var max_bank_level_limit: int = 4 

# 修正係數 (用於 Hex 疊加)
var income_multiplyer: float = 1.0
var income_additioner: float = 0.0
var upgrade_multiplayer: float = 1.0
var upgrade_additioner: float = 0.0
#endregion

#region 2. 機制參數 (Internal Variables)
var bank_active: bool = false
var money_amount: float = 0
var money_CD: float = 0
var current_bank_level: int = 1

@onready var GM: Node2D = get_parent()
@onready var money_text   = GM.get_node("CanvasLayer/HUD_Root/TopBar_BG/TopBar/MoneySegment/HBoxContainer/VBoxContainer/Money_text")
@onready var upgrade_btn  = GM.get_node("CanvasLayer/HUD_Root/TopBar_BG/TopBar/UpgradeBtn")
@onready var income_badge = GM.get_node("CanvasLayer/HUD_Root/TopBar_BG/TopBar/MoneySegment/HBoxContainer/IncomeBadge")

var bank_upgrade_map = {
	1: [2,  30],
	2: [6,  90],
	3: [12, 180],
	4: [22, 330],
	5: [32, 480],
	6: [44, 660],
	7: [66, 1980],
	8: [134, 999999] 
}
#endregion

#region 3. 生命周期 (Lifecycle)
func _ready() -> void:
	await get_tree().process_frame
	SignalBus.connect("buy_unit", buy_unit)
	SignalBus.connect("try_upgrade_bank", upgrade_bank)
	reset_bank()

func _process(delta: float) -> void:
	if not bank_active:
		return
		
	if money_CD >= 1.0:
		get_fund(bank_upgrade_map[current_bank_level][0])
		money_CD = 0
	else:
		money_CD += delta
#endregion

#region 4. 外部接口 - 修改器 (Modifier APIs)

## 新增：調整銀行等級上限鎖定
func unlock_max_level(new_limit: int):
	# 確保新上限不會超過 map 的總定義長度
	max_bank_level_limit = min(new_limit, bank_upgrade_map.size())
	update_text()
	print("Bank max level unlocked to: ", max_bank_level_limit)

func add_income_modifier(mul: float, add: float):
	income_multiplyer *= mul
	income_additioner += add
	update_text()

func add_upgrade_modifier(mul: float, add: float):
	upgrade_multiplayer *= mul
	upgrade_additioner += add
	update_text()

func reset_modifiers():
	income_multiplyer = 1.0
	income_additioner = 0.0
	upgrade_multiplayer = 1.0
	upgrade_additioner = 0.0
	update_text()
#endregion

#region 5. 核心邏輯 (Core Logic)

func get_fund(base_amount: float):
	money_amount += (base_amount * income_multiplyer) + income_additioner
	update_text()

func buy_unit(unit_id: String):
	var cost = UnitAutoload.unit_dic[unit_id].cost
	if money_amount >= cost:
		SignalBus.emit_signal("spawn_unit_by_name", unit_id)
		money_amount -= cost
		update_text()

func upgrade_bank():
	# 修改：增加對 max_bank_level_limit 的檢查
	if current_bank_level >= max_bank_level_limit: 
		print("Bank level is currently capped!")
		return
	
	if current_bank_level >= bank_upgrade_map.size(): return
	
	var base_cost = bank_upgrade_map[current_bank_level][1]
	var final_cost = (base_cost * upgrade_multiplayer) + upgrade_additioner
	
	if money_amount >= final_cost:
		money_amount -= final_cost
		current_bank_level += 1
		update_text()

func function_switch(b: bool):
	bank_active = b

func reset_bank():
	current_bank_level = default_bank_level
	money_amount = 0
	money_CD = 0
	update_text()

func start_level():
	money_amount += default_money_amount
	current_bank_level = max(current_bank_level - 1, 1)
	update_text()

func update_text():
	if not money_text: return
	
	var base_income = bank_upgrade_map[current_bank_level][0]
	var base_upgrade_cost = bank_upgrade_map[current_bank_level][1]
	
	var current_income = (base_income * income_multiplyer) + income_additioner
	var current_upgrade_cost = (base_upgrade_cost * upgrade_multiplayer) + upgrade_additioner
	
	money_text.text = tr("$") + str(snapped(money_amount, 1))
	
	if income_badge:
		income_badge.text = "+" + str(snapped(current_income, 0.1)) + tr("/s")
	
	if upgrade_btn:
		# 修改：如果達到鎖定上限，同樣顯示 MAX LEVEL 並禁用按鈕
		if current_bank_level >= max_bank_level_limit or current_bank_level >= bank_upgrade_map.size():
			upgrade_btn.text = "⬆ " + tr("BANK_MAX_LEVEL")
			upgrade_btn.disabled = true
		else:
			upgrade_btn.text = "⬆ " + tr("BANK_UPGRADE_INCOME") + "\n" + tr("$") + str(snapped(current_upgrade_cost, 1))
			upgrade_btn.disabled = (money_amount < current_upgrade_cost)
#endregion
