extends Button

#region 1. 變量與配置 (Properties & Settings)
@export var unit_id: String
const BTN_SIZE = Vector2(90, 100)

var _origin_y: float
var _cd_max: float = 0.0
var _cd_timer: float = 0.0

# --- CD 修正接口 ---
var _cd_multiplyer: float = 1.0  # 乘法修正 (例如 0.8 代表 CD 變 80%)
var _cd_additioner: float = 0.0  # 加法修正 (例如 -0.5 代表 CD 減 0.5秒)
# ------------------

var _cd_overlay: ColorRect  # 遮罩節點
#endregion

#region 2. 生命周期 (Lifecycle)
func _ready() -> void:
	await get_tree().process_frame
	_origin_y = position.y
	self.connect("pressed", on_pressed)
	self.connect("mouse_entered", on_hover_enter)
	self.connect("mouse_exited", on_hover_exit)
	custom_minimum_size = BTN_SIZE
	_build_ui()
	
	# 讀取原始數據
	var data = UnitAutoload.unit_dic[unit_id]
	_cd_max = data.deploy_cd
	
	SignalBus.spawn_unit_by_name.connect(_on_unit_spawned)

func _process(delta: float) -> void:
	if _cd_timer <= 0:
		return
	
	_cd_timer -= delta
	
	if _cd_timer <= 0:
		_cd_timer = 0
		_set_cd_active(false)
		return
	
	# 更新遮罩與數字
	var current_effective_max = get_effective_cd()
	var ratio = _cd_timer / current_effective_max
	var full_h = _cd_overlay.get_parent().size.y
	_cd_overlay.size.y = full_h * ratio
	
	var cd_label = _cd_overlay.get_parent().get_node("CDLabel")
	cd_label.text = str(snappedf(_cd_timer, 0.1))
#endregion

#region 3. 外部接口 (Public API - 修正接口)
## 提供給 Hex Card 或 GM 調用，例如: btn.apply_cd_modifier(1.0, -0.5)
func apply_cd_modifier(mul: float, add: float):
	_cd_multiplyer = mul
	_cd_additioner = add
	# 如果想讓當前正在跑的 CD 也立刻縮短，可以取消註解下面邏輯
	# _cd_timer = clamp(_cd_timer, 0, get_effective_cd())
func add_cd_modifier(mul: float, add: float):
	# 乘法疊加：原本 0.8 倍再疊加 0.8 倍會變成 0.64 倍
	_cd_multiplyer *= mul
	# 加法疊加：原本減 0.5s 再疊加減 0.5s 會變成減 1.0s
	_cd_additioner += add
	
	# [可選] 如果縮短了 CD，讓當前正在冷卻的進度條也按比例縮短（防止溢出）
	if _cd_timer > 0:
		_cd_timer = clamp(_cd_timer, 0, get_effective_cd())
## 計算最終生效的 CD 時間
func get_effective_cd() -> float:
	# 公式：(基礎CD * 倍率) + 增減值，並確保不小於 0.1 秒
	return max(0.1, (_cd_max * _cd_multiplyer) + _cd_additioner)
#endregion

#region 4. UI 構建與樣式 (UI & Styles)
func _build_ui():
	var data = UnitAutoload.unit_dic[unit_id]
	text = ""
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 4)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(vbox)
	
	var hotkey = Label.new()
	hotkey.text = _get_hotkey()
	hotkey.add_theme_font_size_override("font_size", 9)
	hotkey.add_theme_color_override("font_color", Color("5a7090"))
	hotkey.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	hotkey.position = Vector2(4, 2)
	hotkey.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hotkey)
	
	var portrait_bg = PanelContainer.new()
	portrait_bg.custom_minimum_size = Vector2(50, 50)
	portrait_bg.size = Vector2(50, 50)
	portrait_bg.clip_contents = true
	portrait_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_apply_portrait_style(portrait_bg, data)
	vbox.add_child(portrait_bg)
	
	var portrait_icon = TextureRect.new()
	portrait_icon.texture = data.image
	portrait_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait_icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	portrait_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait_bg.add_child(portrait_icon)
	
	_cd_overlay = ColorRect.new()
	_cd_overlay.color = Color(0, 0, 0, 0.65)
	_cd_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_cd_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cd_overlay.visible = false
	portrait_bg.add_child(_cd_overlay)
	
	var cd_label = Label.new()
	cd_label.name = "CDLabel"
	cd_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cd_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cd_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cd_label.add_theme_font_size_override("font_size", 18)
	cd_label.add_theme_color_override("font_color", Color("e8e8e8"))
	cd_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cd_label.visible = false
	portrait_bg.add_child(cd_label)
	
	var name_label = Label.new()
	name_label.text = data.minion_name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 13)
	name_label.add_theme_color_override("font_color", Color("c8d8e8"))
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(name_label)
	
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
	style.border_color = Color("c84ae8") if data.cost >= 70 else Color("6a4ae8") if data.cost >= 40 else Color("e8c84a")
	style.corner_radius_top_left = 2
	style.corner_radius_top_right = 2
	style.corner_radius_bottom_left = 2
	style.corner_radius_bottom_right = 2
	panel.add_theme_stylebox_override("panel", style)

func _get_hotkey() -> String:
	const keys = ["Q","W","E","R","T","Y","U","I"]
	var idx = get_index()
	return keys[idx] if idx < keys.size() else ""
#endregion

#region 5. 交互邏輯 (Interactions)
func on_pressed():
	var tw = create_tween()
	tw.tween_property(self, "scale", Vector2(0.95, 0.95), 0.05)
	tw.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
	SignalBus.emit_signal("buy_unit", unit_id)

func on_hover_enter():
	create_tween().tween_property(self, "position:y", _origin_y - 3, 0.1)

func on_hover_exit():
	create_tween().tween_property(self, "position:y", _origin_y, 0.1)

func _set_cd_active(active: bool) -> void:
	var cd_label = _cd_overlay.get_parent().get_node("CDLabel")
	_cd_overlay.visible = active
	cd_label.visible = active
	disabled = active

func _on_unit_spawned(spawned_id: String) -> void:
	if spawned_id == unit_id:
		# 使用計算後的生效 CD
		_cd_timer = get_effective_cd()
		_set_cd_active(true)
#endregion
