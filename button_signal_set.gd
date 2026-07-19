extends Node




func _on_money_upgrade_pressed() -> void:
	SignalBus.emit_signal("try_upgrade_bank")




func _on_unit_gallery_button_pressed() -> void:
	SignalBus.open_unit_gallery.emit()


func _on_upgrade_btn_pressed() -> void:
	SignalBus.emit_signal("try_upgrade_bank")


func _on_setting_button_pressed() -> void:
	SignalBus.open_setting.emit()


func _on_hex_show_button_pressed() -> void:
	SignalBus.open_hex_show_window.emit()

func _input(event: InputEvent) -> void:
	if event.is_pressed() and event.is_action("esc"):
		SignalBus.open_setting.emit()
