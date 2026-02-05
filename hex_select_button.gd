extends Button

var good_hex = "nothing"
var bad_hex = "nothing"

func _ready() -> void:
	self.pressed.connect(hex_select)


func hex_select():
	SignalBus.hex_select.emit([good_hex,bad_hex])
