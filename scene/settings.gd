extends PanelContainer

@onready var music_slider: HSlider = $VBox/MusicRow/HSlider
@onready var sfx_slider: HSlider = $VBox/SFXRow/HSlider
@onready var music_label: Label = $VBox/MusicRow/ValueLabel
@onready var sfx_label: Label = $VBox/SFXRow/ValueLabel
@onready var fullscreen_btn: Button = $VBox/WindowRow/Fullscreen
@onready var resolution_option: OptionButton = $VBox/WindowRow/ResolutionOption

@onready var language_title: Label = $VBox/LanguaueRow/Title
@onready var language_option_button: OptionButton = $VBox/LanguaueRow/OptionButton
@onready var music_title: Label = $VBox/MusicRow/Label
@onready var sfx_title: Label = $VBox/SFXRow/Label
@onready var window_title: Label = $VBox/WindowRow/Label

@onready var close_btn: Button = $VBox/HBoxContainer/CloseButton
@onready var quit_btn: Button = $VBox/HBoxContainer/Button

func _ready() -> void:
	GlobalSettings.populate_language_options(self)
	GlobalSettings.populate_resolution_options(self)

	music_slider.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))
	sfx_slider.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))
	GlobalSettings.update_fullscreen_btn(self)

	close_btn.pressed.connect(GlobalSettings.on_close.bind(self))
	quit_btn.pressed.connect(GlobalSettings.on_quit.bind(self))
	music_slider.value_changed.connect(GlobalSettings.on_music_changed.bind(self))
	sfx_slider.value_changed.connect(GlobalSettings.on_sfx_changed.bind(self))
	fullscreen_btn.pressed.connect(GlobalSettings.on_fullscreen_toggle.bind(self))

	GlobalSettings.refresh_texts(self)
	Global.slide_in(self, 30.0)
