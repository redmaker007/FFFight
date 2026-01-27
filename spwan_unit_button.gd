extends Button

@export var unit_name:String

func _ready() -> void:
	self.connect("pressed",on_pressed)
	self.text = unit_name




func on_pressed():
	SignalBus.emit_signal("spawn_unit_by_name",unit_name)
