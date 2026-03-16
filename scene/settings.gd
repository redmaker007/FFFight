extends PanelContainer

@onready var music_slider: HSlider = $VBox/MusicRow/HSlider
@onready var sfx_slider: HSlider = $VBox/SFXRow/HSlider
@onready var music_label: Label = $VBox/MusicRow/ValueLabel
@onready var sfx_label: Label = $VBox/SFXRow/ValueLabel
@onready var fullscreen_btn: Button = $VBox/WindowRow/Fullscreen

@onready var language_title: Label = $VBox/LanguaueRow/Title
@onready var language_option_button: OptionButton = $VBox/LanguaueRow/OptionButton
@onready var music_title: Label = $VBox/MusicRow/Label
@onready var sfx_title: Label = $VBox/SFXRow/Label
@onready var window_title: Label = $VBox/WindowRow/Label

@onready var close_btn: Button = $VBox/HBoxContainer/CloseButton
@onready var quit_btn: Button = $VBox/HBoxContainer/Button

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
	_load_settings()
	_populate_language_options()

	music_slider.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))
	sfx_slider.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))
	_update_fullscreen_btn()

	close_btn.pressed.connect(_on_close)
	quit_btn.pressed.connect(_on_quit)
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	fullscreen_btn.pressed.connect(_on_fullscreen_toggle)

	_refresh_texts()
	Global.slide_in(self, 30.0)


func _populate_language_options() -> void:
	language_option_button.clear()
	var saved_locale: String = TranslationServer.get_locale()
	var select_index: int = 0
	
	var loaded_locales = TranslationServer.get_loaded_locales()
	if loaded_locales.is_empty():
		loaded_locales = ["en"]
		
	
	for i in loaded_locales.size():
		var locale: String = loaded_locales[i]
		var display: String = locale_display_names.get(locale, locale)
		language_option_button.add_item(display, i)
		if locale == saved_locale:
			select_index = i
	
	language_option_button.select(select_index)
	language_option_button.item_selected.connect(_on_language_selected)

func _on_language_selected(index: int) -> void:
	var loaded_locales = TranslationServer.get_loaded_locales()
	var locale: String = loaded_locales[index]
	TranslationServer.set_locale(locale)
	_refresh_texts()


func _refresh_texts() -> void:
	language_title.text = tr("LANGUAGE")
	music_title.text = tr("MUSIC")
	sfx_title.text = tr("SFX")
	window_title.text = tr("DISPLAY")
	_update_fullscreen_btn()
	SignalBus.on_language_change.emit()


func _on_music_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), value)
	music_label.text = str(int(value + 60)) # -60db~0db mapped to 0~60 display


func _on_sfx_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), value)
	sfx_label.text = str(int(value + 60))


func _on_fullscreen_toggle() -> void:
	var is_fullscreen = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	if is_fullscreen:
		get_window().mode = Window.MODE_WINDOWED
	else:
		get_window().mode = Window.MODE_FULLSCREEN
	await get_tree().process_frame
	_update_fullscreen_btn()


func _update_fullscreen_btn() -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		fullscreen_btn.text = "■  " + tr("WINDOWED")
	else:
		fullscreen_btn.text = "⛶  " + tr("FULLSCREEN")


func _on_close() -> void:
	SignalBus.gm_switch_state.emit("play")
	print("close pressed")
	_save_settings()
	queue_free()


func _on_quit() -> void:
	get_tree().quit()


func _save_settings() -> void:
	var config = ConfigFile.new()
	config.set_value("audio", "music_db", music_slider.value)
	config.set_value("audio", "sfx_db", sfx_slider.value)
	config.set_value("language", "locale", TranslationServer.get_locale())
	config.save("user://settings.cfg")


func _load_settings() -> void:
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		music_slider.value = config.get_value("audio", "music_db", 0.0)
		sfx_slider.value = config.get_value("audio", "sfx_db", 0.0)
		var locale: String = config.get_value("language", "locale", "en")
		TranslationServer.set_locale(locale)
