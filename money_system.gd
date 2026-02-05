extends Node
#公开参数
var default_money_amount =100
var default_bank_level = 1

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
	money_amount += amount
	money_text.text = "$: "+str(money_amount)

func buy_unit(unit_name):
	var cost = GM.mm.mm[unit_name]["cost"]
	if money_amount >= cost:
		SignalBus.emit_signal("spawn_unit_by_name",unit_name)
		money_amount -= cost
		money_text.text = "$: "+str(money_amount)

func upgrade_bank():
	var cost =bank_upgrade_map[current_bank_level][1]
	if money_amount >= cost:
		money_amount -=cost
		money_text.text = "$: "+str(money_amount)
		current_bank_level+=1
		get_parent().get_node("CanvasLayer/HBoxContainer2/money_upgrade/money_upgrade_text").text = str(bank_upgrade_map[current_bank_level][1])

func start_level():
	money_amount += default_money_amount
	current_bank_level = default_bank_level
	money_text.text = "$: "+str(money_amount)
	get_parent().get_node("CanvasLayer/HBoxContainer2/money_upgrade/money_upgrade_text").text = str(bank_upgrade_map[current_bank_level][1])


func reset_bank():
	current_bank_level = default_bank_level
	money_amount = 0
	money_text.text = "$: "+str(money_amount)
	get_parent().get_node("CanvasLayer/HBoxContainer2/money_upgrade/money_upgrade_text").text = str(bank_upgrade_map[current_bank_level][1])
