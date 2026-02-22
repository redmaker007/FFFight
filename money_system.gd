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

var current_bank_level = 1

var bank_upgrade_map ={
	1:[1,45],
	2:[4,90],
	3:[8,175],
	4:[13,300],
	5:[19,450],
	6:[26,700],
	7:[38,9999],
}

@onready var GM:Node2D = get_parent()
@onready var money_text = GM.get_node("CanvasLayer/HBoxContainer2/Money_text")

func _ready() -> void:
	SignalBus.connect("buy_unit",buy_unit)
	SignalBus.connect("try_upgrade_bank",upgrade_bank)
	money_amount = 100
	current_bank_level = 1
	get_parent().get_node("CanvasLayer/HBoxContainer2/money_upgrade/money_upgrade_text").text = str(bank_upgrade_map[current_bank_level][1])

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
	current_bank_level = default_bank_level
	update_text()

func reset_bank():
	current_bank_level = default_bank_level
	money_amount = 0
	update_text()
	
func update_text():
	# 升级费用的 UI 更新保持不变
	get_parent().get_node("CanvasLayer/HBoxContainer2/money_upgrade/money_upgrade_text").text = str(bank_upgrade_map[current_bank_level][1] * upgrade_multiplayer)
	
	# 💡 计算当前的实际秒收 (基础秒收 * 收入倍率)
	var current_income = bank_upgrade_map[current_bank_level][0] * income_multiplyer
	
	# 💡 拼接字符串，加入了 (+X/s) 的显示。
	# 为了防止倍率导致出现长小数，给 current_income 也加上了 snapped 处理
	money_text.text = "$: " + str(snapped(money_amount, 0.01)) + " (+" + str(snapped(current_income, 0.01)) + "/s)"
