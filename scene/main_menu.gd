# main_menu.gd
extends Control

@onready var btn_start: Button = $VBoxContainer/ButtonContainer/BtnStart
@onready var btn_achievements: Button = $VBoxContainer/ButtonContainer/BtnAchievements
@onready var btn_settings: Button = $VBoxContainer/ButtonContainer/BtnSettings
@onready var btn_quit: Button = $VBoxContainer/ButtonContainer/BtnQuit

const GAME_SCENE = "res://scene/node_2d.tscn"

func _ready() -> void:
	btn_start.pressed.connect(_on_start)
	# btn_achievements.pressed.connect(_on_achievements)
	btn_settings.pressed.connect(_on_settings)
	btn_quit.pressed.connect(_on_quit)

func _on_start() -> void:
	_play_exit_animation(func(): get_tree().change_scene_to_file(GAME_SCENE))

# func _on_achievements() -> void:
# 	pass



func _on_quit() -> void:
	_play_exit_animation(func(): get_tree().quit())

func _play_exit_animation(callback: Callable) -> void:
	var tw = create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.25)
	await tw.finished
	callback.call()


const SETTINGS_SCENE = preload("res://scene/Settings.tscn")
var _settings_instance = null

func _on_settings() -> void:
	if _settings_instance:
		return  # 防止重复打开
	_settings_instance = SETTINGS_SCENE.instantiate()
	add_child(_settings_instance)
	# 监听设置界面关闭信号
	_settings_instance.tree_exited.connect(func(): _settings_instance = null)
