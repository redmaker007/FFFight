extends Button

#region 1. 變量與配置 (Properties & Settings)
@export var unit_id: String

@export_group("Button Size")
@export var btn_size: Vector2 = Vector2(90, 130)
@export var portrait_size: Vector2 = Vector2(50, 50)
@export var upgrade_btn_size: Vector2 = Vector2(82, 18)
@export var vbox_separation: int = 4
@export var hover_lift: float = 3.0

@export_group("Font Sizes")
@export var font_size_hotkey: int = 9
@export var font_size_cd: int = 18
@export var font_size_name: int = 13
@export var font_size_cost: int = 12
@export var font_size_upgrade: int = 9
@export var font_size_exp: int = 9

@export_group("Upgrade")
@export var upgrade_cost: int = 10

var _origin_y: float
var _cd_max: float = 0.0
var _cd_timer: float = 0.0

# --- CD 修正接口 ---
var _cd_multiplyer: float = 1.0
var _cd_additioner: float = 0.0
# ------------------

var _cd_overlay: ColorRect
var _name_label: Label

# --- 升級系統 ---
var _gm: Node = null
var _active_minion: ActiveMinion = null
var _upgrade_btn: Button = null
var _exp_label: Label = null
#endregion

#region 2. 生命周期 (Lifecycle)
func _ready() -> void:
	await get_tree().process_frame
	_gm = get_tree().current_scene
	self.connect("pressed", on_pressed)
	self.connect("mouse_entered", on_hover_enter)
	self.connect("mouse_exited", on_hover_exit)
	custom_minimum_size = btn_size
	_build_ui()

	var data = UnitAutoload.unit_dic[unit_id]
	_cd_max = data.deploy_cd

	SignalBus.spawn_unit_by_name.connect(_on_unit_spawned)
	SignalBus.unit_spawned.connect(_on_unit_spawned_apply_level)
	SignalBus.on_language_change.connect(update_ui_texts)

	# 監聽 inventory：shop 購買後才知道對應 ActiveMinion
	var inv = _gm.get_node("Inventory_manager")
	inv.minion_added.connect(_on_minion_added)
	_find_and_setup_active_minion()


func _exit_tree() -> void:
	if _active_minion != null and _active_minion.leveled_up.is_connected(_on_leveled_up):
		_active_minion.leveled_up.disconnect(_on_leveled_up)

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
	vbox.add_theme_constant_override("separation", vbox_separation)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(vbox)

	var hotkey = Label.new()
	hotkey.text = _get_hotkey()
	hotkey.add_theme_font_size_override("font_size", font_size_hotkey)
	hotkey.add_theme_color_override("font_color", Color("5a7090"))
	hotkey.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	hotkey.position = Vector2(4, 2)
	hotkey.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hotkey)

	var portrait_bg = PanelContainer.new()
	portrait_bg.custom_minimum_size = portrait_size
	portrait_bg.size = portrait_size
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
	cd_label.add_theme_font_size_override("font_size", font_size_cd)
	cd_label.add_theme_color_override("font_color", Color("e8e8e8"))
	cd_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cd_label.visible = false
	portrait_bg.add_child(cd_label)

	_name_label = Label.new()
	_name_label.text = tr(data.get_name_key())
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name_label.add_theme_font_size_override("font_size", font_size_name)
	_name_label.add_theme_color_override("font_color", Color("c8d8e8"))
	_name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(_name_label)

	var cost_label = Label.new()
	cost_label.text = "$" + str(data.cost)
	cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cost_label.add_theme_font_size_override("font_size", font_size_cost)
	cost_label.add_theme_color_override("font_color", Color("e8c84a"))
	cost_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(cost_label)

	_upgrade_btn = Button.new()
	_upgrade_btn.text = tr("UPGRADE") + " $" + str(upgrade_cost)
	_upgrade_btn.add_theme_font_size_override("font_size", font_size_upgrade)
	_upgrade_btn.custom_minimum_size = upgrade_btn_size
	_upgrade_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	_upgrade_btn.pressed.connect(_on_upgrade_pressed)
	_upgrade_btn.disabled = true
	vbox.add_child(_upgrade_btn)

	_exp_label = Label.new()
	_exp_label.text = "0/10"
	_exp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_exp_label.add_theme_font_size_override("font_size", font_size_exp)
	_exp_label.add_theme_color_override("font_color", Color("88ccff"))
	_exp_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(_exp_label)

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
	_origin_y = position.y
	create_tween().tween_property(self, "position:y", _origin_y - hover_lift, 0.1)

func on_hover_exit():
	create_tween().tween_property(self, "position:y", _origin_y, 0.1)

func _set_cd_active(active: bool) -> void:
	var cd_label = _cd_overlay.get_parent().get_node("CDLabel")
	_cd_overlay.visible = active
	cd_label.visible = active
	disabled = active

func _on_unit_spawned(spawned_id: String) -> void:
	if spawned_id == unit_id:
		_cd_timer = get_effective_cd()
		_set_cd_active(true)

func update_ui_texts():
	var data = UnitAutoload.unit_dic[unit_id]
	if _name_label:
		_name_label.text = tr(data.get_name_key())
	_refresh_upgrade_ui()


# ── 升級系統 ────────────────────────────────────────────────

func _find_and_setup_active_minion() -> void:
	if _gm == null:
		return
	var inv = _gm.get_node("Inventory_manager")
	for am in inv.active_minions:
		if am.data.minion_id == unit_id:
			_link_active_minion(am)
			return

func _link_active_minion(am: ActiveMinion) -> void:
	_active_minion = am
	if not am.leveled_up.is_connected(_on_leveled_up):
		am.leveled_up.connect(_on_leveled_up)
	_refresh_upgrade_ui()

func _on_minion_added(minion: ActiveMinion) -> void:
	if minion.data.minion_id == unit_id and _active_minion == null:
		_link_active_minion(minion)

func _refresh_upgrade_ui() -> void:
	if _upgrade_btn == null or _exp_label == null:
		return
	if _active_minion == null:
		_upgrade_btn.disabled = true
		_upgrade_btn.text = tr("UPGRADE") + " $" + str(upgrade_cost)
		_exp_label.text = "0/10"
		return
	if _active_minion.current_level >= 3:
		_upgrade_btn.disabled = true
		_upgrade_btn.text = tr("UNIT_MAX_LEVEL")
		_exp_label.text = "MAX"
	else:
		_upgrade_btn.disabled = false
		_upgrade_btn.text = tr("UPGRADE") + " $" + str(upgrade_cost)
		_exp_label.text = "Lv.%d  %d/10" % [_active_minion.current_level, _active_minion.experience]

func _on_upgrade_pressed() -> void:
	if _active_minion == null or _active_minion.current_level >= 3:
		return
	if _gm.ms.money_amount < upgrade_cost:
		return
	_gm.ms.force_deduct(upgrade_cost)
	_active_minion.add_experience(1)
	_refresh_upgrade_ui()

func _on_leveled_up(new_level: int) -> void:
	# 對場上現有的同類友方單位套用 +20% max_hp
	for unit in get_tree().get_nodes_in_group("ally"):
		if unit.get("unit_id") == unit_id:
			unit.add_mod("max_hp", 0.2, false)
			unit.stat_dic["hp"] = minf(unit.stat_dic["hp"] * 1.2, unit.get_moded_stat("max_hp"))
			unit.refresh()
	_refresh_upgrade_ui()

func _on_unit_spawned_apply_level(unit: Node) -> void:
	# 新生成的單位按已累積等級套 mod
	if unit.get("unit_id") != unit_id or unit.get("side") != "ally":
		return
	if _active_minion == null or _active_minion.current_level <= 1:
		return
	for i in range(_active_minion.current_level - 1):
		unit.add_mod("max_hp", 0.2, false)
	unit.stat_dic["hp"] = unit.get_moded_stat("max_hp")
	unit.refresh()
#endregion
