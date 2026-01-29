extends Node

var money_amount = 100
var money_CD = 1

@onready var GM:Node2D = get_parent()
@onready var money_text = GM.get_node("CanvasLayer/Money_text")

func _ready() -> void:
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
