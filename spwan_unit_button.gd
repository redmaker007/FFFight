extends Button

#region 1. 變量與配置 (Properties & Settings)
@export var unit_id: String
@export var hover_lift: float = 3.0

@export_group("Upgrade")
@export var upgrade_cost: int = 10

@export_group("Node References")
@export var portrait_icon: TextureRect
@export var cd_overlay: ColorRect
@export var cd_label: Label
@export var name_label: Label
@export var cost_label: Label
@export var hotkey_label: Label
@export var upgrade_btn: Button
@export var exp_label: Label

var _origin_y: float
var _cd_max: float = 0.0
var _cd_timer: float = 0.0

# --- CD 修正接口 ---
var _cd_multiplyer: float = 1.0
var _cd_additioner: float = 0.0
# ------------------

# --- 升級系統 ---
var _gm: Node = null
var _active_minion: ActiveMinion = null
#endregion

#region 2. 生命周期 (Lifecycle)
func _ready() -> void:
	await get_tree().process_frame
	_gm = get_tree().current_scene
	connect("pressed", on_pressed)
	connect("mouse_entered", on_hover_enter)
	connect("mouse_exited", on_hover_exit)

	var data = UnitAutoload.unit_dic[unit_id]
	_cd_max = data.deploy_cd
	_init_display(data)

	if upgrade_btn:
		upgrade_btn.pressed.connect(_on_upgrade_pressed)
		upgrade_btn.disabled = true
		upgrade_btn.mouse_filter = Control.MOUSE_FILTER_STOP

	SignalBus.spawn_unit_by_name.connect(_on_unit_spawned)
	SignalBus.unit_spawned.connect(_on_unit_spawned_apply_level)
	SignalBus.on_language_change.connect(update_ui_texts)

	var inv = _gm.get_node("Inventory_manager")
	inv.minion_added.connect(_on_minion_added)
	_find_and_setup_active_minion()

func _init_display(data: minion_data) -> void:
	if portrait_icon:
		portrait_icon.texture = data.image
	if name_label:
		name_label.text = tr(data.get_name_key())
	if cost_label:
		cost_label.text = "$" + str(data.cost)
	if hotkey_label:
		hotkey_label.text = _get_hotkey()
	if cd_overlay:
		cd_overlay.visible = false
	if cd_label:
		cd_label.visible = false

func _exit_tree() -> void:
	if _active_minion != null:
		if _active_minion.leveled_up.is_connected(_on_leveled_up):
			_active_minion.leveled_up.disconnect(_on_leveled_up)
		if _active_minion.node_changed.is_connected(_on_node_changed):
			_active_minion.node_changed.disconnect(_on_node_changed)

func _process(delta: float) -> void:
	if _cd_timer <= 0:
		return

	_cd_timer -= delta

	if _cd_timer <= 0:
		_cd_timer = 0
		_set_cd_active(false)
		return

	if cd_overlay:
		var ratio = _cd_timer / get_effective_cd()
		var full_h = cd_overlay.get_parent().size.y
		cd_overlay.size.y = full_h * ratio

	if cd_label:
		cd_label.text = str(snappedf(_cd_timer, 0.1))
#endregion

#region 3. 外部接口 (Public API)
func apply_cd_modifier(mul: float, add: float) -> void:
	_cd_multiplyer = mul
	_cd_additioner = add

func add_cd_modifier(mul: float, add: float) -> void:
	_cd_multiplyer *= mul
	_cd_additioner += add
	if _cd_timer > 0:
		_cd_timer = clamp(_cd_timer, 0, get_effective_cd())

func get_effective_cd() -> float:
	return max(0.1, (_cd_max * _cd_multiplyer) + _cd_additioner)
#endregion

#region 4. 交互邏輯 (Interactions)
func on_pressed() -> void:
	var tw = create_tween()
	tw.tween_property(self, "scale", Vector2(0.95, 0.95), 0.05)
	tw.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
	SignalBus.emit_signal("buy_unit", unit_id)

func on_hover_enter() -> void:
	_origin_y = position.y
	create_tween().tween_property(self, "position:y", _origin_y - hover_lift, 0.1)

func on_hover_exit() -> void:
	create_tween().tween_property(self, "position:y", _origin_y, 0.1)

func _set_cd_active(active: bool) -> void:
	if cd_overlay: cd_overlay.visible = active
	if cd_label:   cd_label.visible   = active
	disabled = active

func _on_unit_spawned(spawned_id: String) -> void:
	if spawned_id == unit_id:
		_cd_timer = get_effective_cd()
		_set_cd_active(true)

func update_ui_texts() -> void:
	var data = UnitAutoload.unit_dic[unit_id]
	if name_label:
		name_label.text = tr(data.get_name_key())
	_refresh_upgrade_ui()

func _get_hotkey() -> String:
	const keys = ["Q","W","E","R","T","Y","U","I"]
	var idx = get_index()
	return keys[idx] if idx < keys.size() else ""
#endregion

#region 5. 升級系統 (Upgrade System)
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
	if not am.node_changed.is_connected(_on_node_changed):
		am.node_changed.connect(_on_node_changed)
	_refresh_upgrade_ui()

func _on_minion_added(minion: ActiveMinion) -> void:
	if minion.data.minion_id == unit_id and _active_minion == null:
		_link_active_minion(minion)

func _refresh_upgrade_ui() -> void:
	if upgrade_btn == null or exp_label == null:
		return
	if _active_minion == null:
		upgrade_btn.disabled = true
		upgrade_btn.text = tr("UPGRADE") + " $" + str(upgrade_cost)
		exp_label.text = "0/10"
		return
	if _active_minion.current_node != null and _active_minion.current_node.is_leaf():
		upgrade_btn.disabled = true
		upgrade_btn.text = tr("UNIT_MAX_LEVEL")
		exp_label.text = "MAX"
	elif _active_minion.current_level >= 3:
		upgrade_btn.disabled = true
		upgrade_btn.text = tr("UNIT_MAX_LEVEL")
		exp_label.text = "MAX"
	else:
		upgrade_btn.disabled = false
		upgrade_btn.text = tr("UPGRADE") + " $" + str(upgrade_cost)
		exp_label.text = "Lv.%d  %d/10" % [_active_minion.current_level, _active_minion.experience]

func _on_upgrade_pressed() -> void:
	if _active_minion == null or _active_minion.current_level >= 3:
		return
	if _gm.ms.money_amount < upgrade_cost:
		return
	_gm.ms.force_deduct(upgrade_cost)
	_active_minion.add_experience(1)
	_refresh_upgrade_ui()

func _on_leveled_up(new_level: int) -> void:
	for unit in get_tree().get_nodes_in_group("ally"):
		if unit.get("unit_id") == unit_id:
			unit.add_mod("max_hp", 0.2, false)
			unit.stat_dic["hp"] = minf(unit.stat_dic["hp"] * 1.2, unit.get_moded_stat("max_hp"))
			unit.refresh()
	_refresh_upgrade_ui()
	SignalBus.open_unit_upgrade_window.emit(_active_minion)

func _on_node_changed(node: UpgradeTreeNode) -> void:
	if node.is_evolution():
		var new_data := node.payload as minion_data
		unit_id = new_data.minion_id
		_cd_max = new_data.deploy_cd
		if portrait_icon: portrait_icon.texture = new_data.image
		if name_label:    name_label.text = tr(new_data.get_name_key())
		if cost_label:    cost_label.text = "$" + str(new_data.cost)
	elif node.is_stat_upgrade():
		for unit in get_tree().get_nodes_in_group("ally"):
			if unit.get("unit_id") == unit_id:
				unit.refresh()
	_refresh_upgrade_ui()

func _on_unit_spawned_apply_level(unit: Node) -> void:
	if unit.get("unit_id") != unit_id or unit.get("side") != "ally":
		return
	if _active_minion == null:
		return
	# 等級 mod（每升一級 +20% max_hp）
	for i in range(_active_minion.current_level - 1):
		unit.add_mod("max_hp", 0.2, false)
	# 綁定 active_minion_ref，讓 get_moded_stat 訪問時自動套用 tree 詞條
	unit.set("active_minion_ref", _active_minion)
	unit.stat_dic["hp"] = unit.get_moded_stat("max_hp")
	unit.refresh()
#endregion
