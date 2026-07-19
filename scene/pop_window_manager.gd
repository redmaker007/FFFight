extends Node

@onready var gm = get_parent()

@export var unit_upgrade_window_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.open_unit_gallery.connect(open_unit_gallery)
	SignalBus.open_setting.connect(open_setting)
	SignalBus.open_hex_show_window.connect(open_hex_show_window)
	SignalBus.open_unit_upgrade_window.connect(open_unit_upgrade_window)

func open_unit_gallery():
	SignalBus.gm_switch_state.emit("pause")
	var ugw = Global.unit_gallery_window.instantiate()
	ugw.z_index = 100
	gm.cl.add_child(ugw)
	
const SETTINGS_SCENE = preload("res://scene/Settings.tscn")
var _settings_instance = null

func open_setting() -> void:
	SignalBus.gm_switch_state.emit("pause")
	if _settings_instance:
		return  # 防止重复打开
	
	_settings_instance = SETTINGS_SCENE.instantiate()
	_settings_instance.z_index = 100
	add_child(_settings_instance)
	# 监听设置界面关闭信号
	_settings_instance.tree_exited.connect(func(): _settings_instance = null)

func open_unit_upgrade_window(am: ActiveMinion) -> void:
	if unit_upgrade_window_scene == null:
		push_warning("pop_window_manager: unit_upgrade_window_scene 未指定")
		return
	var w = unit_upgrade_window_scene.instantiate()
	w.z_index = 100
	gm.cl.add_child(w)
	
	w.setup(am)
	print(w.position)

const hex_show_scene = preload("res://scene/hex_show_window.tscn")
func open_hex_show_window():
	SignalBus.gm_switch_state.emit("pause")
	var h_s_s = hex_show_scene.instantiate()
	h_s_s.z_index = 100
	gm.cl.add_child(h_s_s)
	pass
