extends Button

@export var unit_id: String

const BTN_SIZE = Vector2(90, 100)
var _origin_y: float

func _ready() -> void:
	# 等一帧再记录，确保布局计算完成
	await get_tree().process_frame
	_origin_y = position.y
	self.connect("pressed", on_pressed)
	self.connect("mouse_entered", on_hover_enter)
	self.connect("mouse_exited", on_hover_exit)
	
	custom_minimum_size = BTN_SIZE
	_build_ui()

func _build_ui():
	var data = UnitAutoload.unit_dic[unit_id]
	
	text = ""
	
	# 根容器
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 4)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(vbox)
	
	# 快捷键标签（左上角）
	var hotkey = Label.new()
	hotkey.text = _get_hotkey()
	hotkey.add_theme_font_size_override("font_size", 9)
	hotkey.add_theme_color_override("font_color", Color("5a7090"))
	hotkey.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	hotkey.position = Vector2(4, 2)
	hotkey.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hotkey)
	
	# 头像框
	var portrait_bg = PanelContainer.new()
	portrait_bg.custom_minimum_size = Vector2(50, 50)
	portrait_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_apply_portrait_style(portrait_bg, data)
	vbox.add_child(portrait_bg)
	
	var portrait_icon = TextureRect.new()
	portrait_icon.texture = data.image
	portrait_icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	portrait_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait_icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	portrait_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait_bg.add_child(portrait_icon)
	
	# 单位名
	var name_label = Label.new()
	name_label.text = data.minion_name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 13)
	name_label.add_theme_color_override("font_color", Color("c8d8e8"))
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(name_label)
	
	# 费用
	var cost_label = Label.new()
	cost_label.text = "$" + str(data.cost)
	cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cost_label.add_theme_font_size_override("font_size", 12)
	cost_label.add_theme_color_override("font_color", Color("e8c84a"))
	cost_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(cost_label)

func _apply_portrait_style(panel: PanelContainer, data):
	var style = StyleBoxFlat.new()
	style.bg_color = Color("0d1520")
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	if data.cost >= 70:
		style.border_color = Color("c84ae8")
	elif data.cost >= 40:
		style.border_color = Color("6a4ae8")
	else:
		style.border_color = Color("e8c84a")
	style.corner_radius_top_left = 2
	style.corner_radius_top_right = 2
	style.corner_radius_bottom_left = 2
	style.corner_radius_bottom_right = 2
	panel.add_theme_stylebox_override("panel", style)

func _get_hotkey() -> String:
	const keys = ["Q","W","E","R","T","Y","U","I"]
	var idx = get_index()
	if idx < keys.size():
		return keys[idx]
	return ""

func on_pressed():
	var tw = create_tween()
	tw.tween_property(self, "scale", Vector2(0.95, 0.95), 0.05)
	tw.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
	SignalBus.emit_signal("buy_unit", unit_id)

func on_hover_enter():
	var tw = create_tween()
	tw.tween_property(self, "position:y", _origin_y - 3, 0.1)

func on_hover_exit():
	var tw = create_tween()
	tw.tween_property(self, "position:y", _origin_y, 0.1)
