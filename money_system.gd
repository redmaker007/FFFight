extends Node

var money_amount = 100
var money_CD = 1

@onready var GM:Node2D = get_parent()
@onready var money_text = GM.get_node("CanvasLayer/HBoxContainer2/Money_text")

func _ready() -> void:
	SignalBus.connect("buy_unit",buy_unit)
	money_amount = 100



func _process(delta: float) -> void:
	if money_CD >=1:
		get_fund(1)
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
