extends PanelContainer

var h: hex_data
var lab1
var lab2

func _ready() -> void:
	_apply_panel_style()
	var button = $HBoxContainer/button
	button.pressed.connect(hex_select)
	
	lab1 = $VBoxContainer/Label
	lab2 = $VBoxContainer/Label2
	
	# 正面效果 — 绿色
	lab1.text = "✦ " + h.get_pos_des()
	lab1.add_theme_color_override("font_color", Color("4ae891"))
	lab1.add_theme_font_size_override("font_size", 14)
	
	# 负面效果 — 红色
	lab2.text = "✦ " + h.get_neg_des()
	lab2.add_theme_color_override("font_color", Color("e84a4a"))
	lab2.add_theme_font_size_override("font_size", 12)
	
	# 按钮样式
	_style_select_button(button)

func _apply_panel_style():
	var style = StyleBoxFlat.new()
	style.bg_color = Color("0d1520")
	style.border_color = Color("1e2a3a")
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 3  # 顶部金色边
	style.border_width_bottom = 1
	# 单独设置顶部边颜色需要用 draw 或 shader，简化起见全用金色
	style.set_border_width_all(1)
	style.border_width_top = 2
	style.border_color = Color("9a8230")
	add_theme_stylebox_override("panel", style)

func _style_select_button(btn: Button):
	btn.text = "choose"
	btn.add_theme_font_size_override("font_size", 13)
	btn.add_theme_color_override("font_color", Color("e8c84a"))
	
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = Color("00000000")  # 透明
	normal_style.border_color = Color("9a8230")
	normal_style.set_border_width_all(1)
	btn.add_theme_stylebox_override("normal", normal_style)
	
	var hover_style = StyleBoxFlat.new()
	hover_style.bg_color = Color("e8c84a")
	hover_style.set_border_width_all(1)
	hover_style.border_color = Color("e8c84a")
	btn.add_theme_stylebox_override("hover", hover_style)

func hex_select():
	SignalBus.hex_select.emit(h)
