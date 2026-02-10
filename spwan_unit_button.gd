extends Button

@export var unit_id:String

func _ready() -> void:
	self.connect("pressed",on_pressed)
	print()
	self.text = UnitAutoload.unit_dic[unit_id].minion_name+ "\n"+"$: "+str(UnitAutoload.unit_dic[unit_id].cost)




func on_pressed():
	SignalBus.emit_signal("buy_unit",unit_id)
