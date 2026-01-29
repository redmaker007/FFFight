extends Button

@export var unit_name:String

func _ready() -> void:
	self.connect("pressed",on_pressed)
	print()
	self.text = unit_name+ "\n"+"$: "+str(get_parent().get_parent().get_parent().get_node("minion_map").mm[unit_name]["cost"])




func on_pressed():
	SignalBus.emit_signal("buy_unit",unit_name)
