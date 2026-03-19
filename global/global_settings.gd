extends Node

const locale_display_names: Dictionary = {
	"en": "English",
	"zh_CN": "中文（简体）",
	"zh_TW": "中文（繁體）",
	"ja": "日本語",
	"ko": "한국어",
	"fr": "Français",
	"de": "Deutsch",
	"es": "Español",
	"pt_BR": "Português (BR)",
	"ru": "Русский",
}

const locale_list: Array = ["en", "zh_CN", "zh_TW", "ja", "ko", "fr", "de", "es", "pt_BR", "ru"]


func populate_language_options(panel) -> void:
	panel.language_option_button.clear()
	var saved_locale: String = TranslationServer.get_locale()
	var select_index: int = 0

	var loaded_locales = TranslationServer.get_loaded_locales()
	if loaded_locales.is_empty():
		loaded_locales = ["en"]

	for i in loaded_locales.size():
		var locale: String = loaded_locales[i]
		var display: String = locale_display_names.get(locale, locale)
		panel.language_option_button.add_item(display, i)
		if locale == saved_locale:
			select_index = i

	panel.language_option_button.select(select_index)
	panel.language_option_button.item_selected.connect(on_language_selected.bind(panel))


func on_language_selected(index: int, panel) -> void:
	var loaded_locales = TranslationServer.get_loaded_locales()
	var locale: String = loaded_locales[index]
	TranslationServer.set_locale(locale)
	refresh_texts(panel)


func refresh_texts(panel) -> void:
	panel.language_title.text = tr("LANGUAGE")
	panel.music_title.text = tr("MUSIC")
	panel.sfx_title.text = tr("SFX")
	panel.window_title.text = tr("DISPLAY")
	update_fullscreen_btn(panel)
	SignalBus.on_language_change.emit()


func on_music_changed(value: float, panel) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), value)
	panel.music_label.text = str(int(value + 60)) # -60db~0db mapped to 0~60 display


func on_sfx_changed(value: float, panel) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), value)
	panel.sfx_label.text = str(int(value + 60))


func on_fullscreen_toggle(panel) -> void:
	var is_fullscreen = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	if is_fullscreen:
		panel.get_window().mode = Window.MODE_WINDOWED
	else:
		panel.get_window().mode = Window.MODE_FULLSCREEN
	await panel.get_tree().process_frame
	update_fullscreen_btn(panel)


func update_fullscreen_btn(panel) -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		panel.fullscreen_btn.text = "■  " + tr("WINDOWED")
	else:
		panel.fullscreen_btn.text = "⛶  " + tr("FULLSCREEN")


func on_close(panel) -> void:
	SignalBus.gm_switch_state.emit("play")
	print("close pressed")
	save_settings(panel)
	panel.queue_free()


func on_quit(panel) -> void:
	panel.get_tree().quit()


func save_settings(panel) -> void:
	var config = ConfigFile.new()
	config.set_value("audio", "music_db", panel.music_slider.value)
	config.set_value("audio", "sfx_db", panel.sfx_slider.value)
	config.set_value("language", "locale", TranslationServer.get_locale())
	config.save("user://settings.cfg")


func load_settings(panel) -> void:
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		panel.music_slider.value = config.get_value("audio", "music_db", 0.0)
		panel.sfx_slider.value = config.get_value("audio", "sfx_db", 0.0)
		var locale: String = config.get_value("language", "locale", "en")
		TranslationServer.set_locale(locale)
