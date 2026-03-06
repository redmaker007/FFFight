extends PanelContainer

@onready var music_slider: HSlider = $VBox/MusicRow/HSlider
@onready var sfx_slider: HSlider = $VBox/SFXRow/HSlider
@onready var music_label: Label = $VBox/MusicRow/ValueLabel
@onready var sfx_label: Label = $VBox/SFXRow/ValueLabel
@onready var fullscreen_btn: Button = $VBox/WindowRow/Fullscreen

@onready var close_btn:Button = $VBox/HBoxContainer/CloseButton
@onready var quit_btn:Button = $VBox/HBoxContainer/Button

func _ready() -> void:
	
	
	Global.slide_in(self, 30.0)
	
	# 读取已保存的设置
	music_slider.value = AudioServer.get_bus_volume_db(
		AudioServer.get_bus_index("Music")) 
	sfx_slider.value = AudioServer.get_bus_volume_db(
		AudioServer.get_bus_index("SFX"))
	
	_update_fullscreen_btn()
	
	close_btn.pressed.connect(_on_close)
	
	quit_btn.pressed.connect(_on_quit)
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	fullscreen_btn.pressed.connect(_on_fullscreen_toggle)
	
	_load_settings()
	

func _on_music_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), value)
	music_label.text = str(int(value + 60)) # -60db~0db 映射到 0~60显示

func _on_sfx_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), value)
	sfx_label.text = str(int(value + 60))

func _on_fullscreen_toggle() -> void:
	var is_fullscreen = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	if is_fullscreen:
		get_window().mode = Window.MODE_WINDOWED
	else:
		get_window().mode = Window.MODE_FULLSCREEN
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
	config.save("user://settings.cfg")

func _load_settings() -> void:
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		music_slider.value = config.get_value("audio", "music_db", 0.0)
		sfx_slider.value = config.get_value("audio", "sfx_db", 0.0)
