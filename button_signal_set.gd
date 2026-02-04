extends Node




func _on_money_upgrade_pressed() -> void:
	SignalBus.emit_signal("try_upgrade_bank")
