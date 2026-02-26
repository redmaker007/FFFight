extends Node
#公开参数
var default_money_amount =100
var default_bank_level = 1
var income_multiplyer = 1
var upgrade_multiplayer = 1

#机制参数
var bank_active = false
var money_amount = 100
var money_CD = 1

@onready var GM:Node2D = get_parent()

@onready var money_text   = GM.get_node("CanvasLayer/HUD_Root/TopBar_BG/TopBar/MoneySegment/HBoxContainer/VBoxContainer/Money_text")
@onready var upgrade_btn  = GM.get_node("CanvasLayer/HUD_Root/TopBar_BG/TopBar/UpgradeBtn")
@onready var income_badge = GM.get_node("CanvasLayer/HUD_Root/TopBar_BG/TopBar/MoneySegment/HBoxContainer/IncomeBadge")


var current_bank_level = 1

var bank_upgrade_map ={
	1:[1,45],
	2:[3,105],
	3:[6,200],
	4:[11,375],
	5:[16,550],
	6:[22,900],
	7:[33,9999],
	8:[67,99999999]
}




func _ready() -> void:
	await get_tree().process_frame
	SignalBus.connect("buy_unit",buy_unit)
	SignalBus.connect("try_upgrade_bank",upgrade_bank)
	money_amount = 100
	current_bank_level = 1
	upgrade_btn.text = str(bank_upgrade_map[current_bank_level][1])

func function_switch(b):
	bank_active =b

func _process(delta: float) -> void:
	if not bank_active:
		return
	if money_CD >=1:
		get_fund(bank_upgrade_map[current_bank_level][0])
		money_CD =0
	else:
		money_CD += delta


#直接打款
func get_fund(amount):
	money_amount += amount*income_multiplyer
	update_text()

func buy_unit(unit_id):
	var cost = UnitAutoload.unit_dic[unit_id].cost
	if money_amount >= cost:
		SignalBus.emit_signal("spawn_unit_by_name",unit_id)
		money_amount -= cost
		update_text()

func upgrade_bank():
	var cost =bank_upgrade_map[current_bank_level][1]
	if money_amount >= cost*upgrade_multiplayer:
		money_amount -=cost*upgrade_multiplayer
		
		current_bank_level+=1
		update_text()
		
func start_level():
	money_amount += default_money_amount
	current_bank_level = max(current_bank_level-1,1)
	update_text()

func reset_bank():
	current_bank_level = default_bank_level
	money_amount = 0
	update_text()
	
func update_text():
	var upgrade_cost = bank_upgrade_map[current_bank_level][1] * upgrade_multiplayer
	var current_income = bank_upgrade_map[current_bank_level][0] * income_multiplyer
	
	# 主金币显示（Orbitron 字体，金色）
	money_text.text = "$"+str(snapped(money_amount, 1))
	
	# 收入徽章（绿色 "+X/s"）
	
	if income_badge:
		income_badge.text = "+" + str(snapped(current_income, 0.1)) + "/s"
	
	# 升级按钮费用
	
	if upgrade_btn:
		if current_bank_level >= bank_upgrade_map.size():
			upgrade_btn.text = "⬆ max level"
			upgrade_btn.disabled = true
		else:
			upgrade_btn.text = "⬆ upgrade income\n$" + str(upgrade_cost)
			upgrade_btn.disabled = false
