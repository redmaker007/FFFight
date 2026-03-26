extends Node

const RESOLUTIONS: Array = [
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440),
	Vector2i(3840, 2160),
]

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


func _ready() -> void:
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		var music_db: float = config.get_value("audio", "music_db", 0.0)
		var sfx_db: float = config.get_value("audio", "sfx_db", 0.0)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), music_db)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), sfx_db)
		var locale: String = config.get_value("language", "locale", "en")
		TranslationServer.set_locale(locale)
		var fullscreen: bool = config.get_value("window", "fullscreen", false)
		if fullscreen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			var saved_w: int = config.get_value("window", "width", 0)
			var saved_h: int = config.get_value("window", "height", 0)
			if saved_w > 0 and saved_h > 0:
				var res := Vector2i(saved_w, saved_h)
				DisplayServer.window_set_size(res)
				DisplayServer.window_set_position((DisplayServer.screen_get_size() - res) / 2)


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


func _is_fullscreen() -> bool:
	var mode = DisplayServer.window_get_mode()
	return mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN


func populate_resolution_options(panel) -> void:
	panel.resolution_option.clear()
	var current_size: Vector2i = DisplayServer.window_get_size()
	var select_index: int = 0
	for i in RESOLUTIONS.size():
		var res: Vector2i = RESOLUTIONS[i]
		panel.resolution_option.add_item("%dx%d" % [res.x, res.y], i)
		if res == current_size:
			select_index = i
	panel.resolution_option.select(select_index)
	panel.resolution_option.item_selected.connect(on_resolution_selected.bind(panel))
	panel.resolution_option.disabled = _is_fullscreen()


func on_resolution_selected(index: int, _panel) -> void:
	if _is_fullscreen():
		return
	var res: Vector2i = RESOLUTIONS[index]
	DisplayServer.window_set_size(res)
	DisplayServer.window_set_position((DisplayServer.screen_get_size() - res) / 2)


func on_fullscreen_toggle(panel) -> void:
	if _is_embedded_window():
		return
	if _is_fullscreen():
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		var res: Vector2i = RESOLUTIONS[panel.resolution_option.get_selected()]
		DisplayServer.window_set_size(res)
		DisplayServer.window_set_position((DisplayServer.screen_get_size() - res) / 2)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	update_fullscreen_btn(panel)
	panel.resolution_option.disabled = _is_fullscreen()


func _is_embedded_window() -> bool:
	return DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS) == false \
		and OS.has_feature("editor")


func update_fullscreen_btn(panel) -> void:
	if _is_embedded_window():
		panel.fullscreen_btn.text = tr("FULLSCREEN") + " (N/A)"
		panel.fullscreen_btn.disabled = true
		return
	panel.fullscreen_btn.disabled = false
	if _is_fullscreen():
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
	config.set_value("window", "fullscreen", _is_fullscreen())
	var res: Vector2i = RESOLUTIONS[panel.resolution_option.get_selected_id()]
	config.set_value("window", "width", res.x)
	config.set_value("window", "height", res.y)
	config.save("user://settings.cfg")
