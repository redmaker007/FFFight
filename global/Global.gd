extends Node


func _input(event):
	if event.is_action_pressed("ui_fullscreen"):  # 或直接判断按键
		toggle_fullscreen()

func toggle_fullscreen():
	var mode = DisplayServer.window_get_mode()
	var is_fs = mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
	if is_fs:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


static func tween_number(label: Label, from_val: float, to_val: float, duration: float = 0.3):
	var tw = label.create_tween()
	tw.tween_method(
		func(v): label.text = str(snapped(v, 1)),
		from_val,
		to_val,
		duration
	).set_trans(Tween.TRANS_QUAD)

# 按钮按下弹跳
static func btn_bounce(btn: Control):
	var tw = btn.create_tween()
	tw.tween_property(btn, "scale", Vector2(0.92, 0.92), 0.06)
	tw.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.12).set_trans(Tween.TRANS_ELASTIC)

# 面板滑入
static func slide_in(panel: Control, from_y_offset: float = 40.0):
	var original_y = panel.position.y
	panel.position.y += from_y_offset
	panel.modulate.a = 0
	var tw = panel.create_tween()
	tw.set_parallel(true)
	tw.tween_property(panel, "position:y", original_y, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(panel, "modulate:a", 1.0, 0.2)

#preload
var minion_scene = preload("res://scene/minion_node.tscn")

var hex_select_window = preload("res://scene/hex_select_window.tscn")

var unit_gallery_window = preload("res://scene/Unit Gallery.tscn")

var setting_window = preload("res://scene/Settings.tscn")

#color
const C_BG        = Color("0a0c10")
const C_PANEL     = Color("111520")
const C_BORDER    = Color("1e2a3a")
const C_GOLD      = Color("e8c84a")
const C_GOLD_DIM  = Color("9a8230")
const C_RED       = Color("e84a4a")
const C_GREEN     = Color("4ae891")
const C_BLUE      = Color("4a9ee8")
const C_TEXT      = Color("c8d8e8")
const C_TEXT_DIM  = Color("5a7090")
