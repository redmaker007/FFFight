extends PanelContainer

# ── 請在編輯器連接這些節點 ───────────────────────────────────────────────────
@export_group("Stat Panel")
@export var portrait_rect: TextureRect
@export var unit_name_label: Label
@export var level_label: Label
@export var hp_value_label: Label
@export var att_value_label: Label
@export var att_r_value_label: Label
@export var att_spd_value_label: Label
@export var speed_value_label: Label

@export_group("Upgrade Panel")
@export var upgrade_container: Control

var _active_minion: ActiveMinion = null
var _node_buttons: Dictionary = {}   # UpgradeTreeNode → Button
var _node_parent: Dictionary = {}    # UpgradeTreeNode → parent UpgradeTreeNode (root → null)
var _selected_node: UpgradeTreeNode = null

@export_group("Control")
@export var close_btn: Button
# ─────────────────────────────────────────────────────────────────────────────

func _ready() -> void:
	if close_btn:
		close_btn.pressed.connect(_on_close)

## 由 pop_window_manager 在 add_child 後呼叫
func setup(am: ActiveMinion) -> void:
	_active_minion = am
	_populate(am)
	SignalBus.gm_switch_state.emit("pause")
	_play_enter_anim()
	modulate.a = 1.0

# ── 資料填充 ─────────────────────────────────────────────────────────────────

func _populate(am: ActiveMinion) -> void:
	if level_label:
		level_label.text = "Lv.%d" % am.current_level
	_refresh_stat_panel(am)
	_build_tree_ui(am.tree)

## 只刷新左側 stat 面板（進化路綫變更時呼叫）
func _refresh_stat_panel(am: ActiveMinion) -> void:
	var d := am.data
	if d == null:
		return

	if portrait_rect:
		portrait_rect.texture = d.image
	if unit_name_label:
		unit_name_label.text = tr(d.get_name_key())

	var effective_hp := d.max_hp * pow(1.2, am.current_level - 1)
	_fill(hp_value_label,      "%.0f" % effective_hp)
	_fill(att_value_label,     "%.1f" % d.att)
	_fill(att_r_value_label,   "%.1f" % d.att_r)
	_fill(att_spd_value_label, "%.2f" % d.att_spd)
	_fill(speed_value_label,   "%.1f" % d.speed)

func _fill(lbl: Label, val: String) -> void:
	if lbl:
		lbl.text = val

# ── 樹狀圖 UI ────────────────────────────────────────────────────────────────

func _build_tree_ui(tree: UnitUpgradeTree) -> void:
	if upgrade_container == null or tree == null or tree.root == null:
		return
	for c in upgrade_container.get_children():
		c.queue_free()
	_node_buttons.clear()
	_node_parent.clear()
	_node_parent[tree.root] = null
	upgrade_container.add_child(_build_subtree_ui(tree.root))
	_apply_selection_state(_active_minion.current_node)

## 遞迴建立「節點 + 子樹」的 HBoxContainer
func _build_subtree_ui(node: UpgradeTreeNode) -> Control:
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 4)
	

	var btn := _make_node_button(node)
	btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hbox.add_child(btn)

	if not node.is_leaf():
		var arrow := Label.new()
		arrow.text = "→"
		arrow.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		arrow.add_theme_color_override("font_color", Color("5a7090"))
		arrow.add_theme_font_size_override("font_size", 14)
		arrow.mouse_filter = Control.MOUSE_FILTER_IGNORE
		hbox.add_child(arrow)

		var children_vbox := VBoxContainer.new()
		children_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		children_vbox.add_theme_constant_override("separation", 4)
		children_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
		for child in node.children:
			_node_parent[child] = node
			children_vbox.add_child(_build_subtree_ui(child))
		hbox.add_child(children_vbox)

	return hbox

## 根據 payload 型別建立節點按鈕
func _make_node_button(node: UpgradeTreeNode) -> Button:
	var btn := Button.new()
	btn.mouse_filter = Control.MOUSE_FILTER_STOP
	btn.pressed.connect(_on_node_selected.bind(node))

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(vbox)
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	if node.is_evolution():
		var md := node.payload as minion_data
		btn.custom_minimum_size = Vector2(70, 80)

		if md.image:
			var portrait := TextureRect.new()
			portrait.texture = md.image
			portrait.custom_minimum_size = Vector2(40, 40)
			portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
			vbox.add_child(portrait)

		var lbl := Label.new()
		lbl.text = tr(md.get_name_key())
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 10)
		lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vbox.add_child(lbl)

	elif node.is_stat_upgrade():
		var su := node.payload as UnitStatUpgrade
		btn.custom_minimum_size = Vector2(70, 50)

		var stat_lbl := Label.new()
		stat_lbl.text = su.stat_name.to_upper()
		stat_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		stat_lbl.add_theme_font_size_override("font_size", 10)
		stat_lbl.add_theme_color_override("font_color", Color("88ccff"))
		stat_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vbox.add_child(stat_lbl)

		var sign := "+" if su.additive else "×"
		var val_lbl := Label.new()
		val_lbl.text = "%s%.2f" % [sign, su.value]
		val_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		val_lbl.add_theme_font_size_override("font_size", 11)
		val_lbl.add_theme_color_override("font_color", Color("e8c84a"))
		val_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vbox.add_child(val_lbl)

	_node_buttons[node] = btn
	return btn

## 點選節點：若為進化節點則確認路綫並刷新 stat 面板
func _on_node_selected(node: UpgradeTreeNode) -> void:
	_selected_node = node
	if node.is_evolution() and node != _active_minion.tree.root:
		_active_minion.current_node = node
		_active_minion.node_changed.emit(node)
		_refresh_stat_panel(_active_minion)
		_apply_selection_state(node)

## 套用選中標記與兄弟禁用狀態
func _apply_selection_state(selected: UpgradeTreeNode) -> void:
	# 先全部重置
	for n in _node_buttons:
		var btn: Button = _node_buttons[n]
		btn.disabled = false
		btn.modulate = Color.WHITE
		btn.remove_theme_stylebox_override("normal")
		btn.remove_theme_stylebox_override("hover")
		btn.remove_theme_stylebox_override("focus")
		btn.remove_theme_stylebox_override("disabled")

	var sel_style := StyleBoxFlat.new()
	sel_style.bg_color = Color(0.05, 0.15, 0.08)
	sel_style.set_border_width_all(2)
	sel_style.border_color = Color("44ff88")
	sel_style.corner_radius_top_left    = 3
	sel_style.corner_radius_top_right   = 3
	sel_style.corner_radius_bottom_left = 3
	sel_style.corner_radius_bottom_right = 3

	# root 永遠標記為已選
	var root := _active_minion.tree.root
	if _node_buttons.has(root):
		var root_btn: Button = _node_buttons[root]
		root_btn.add_theme_stylebox_override("normal", sel_style)
		root_btn.add_theme_stylebox_override("hover",  sel_style)
		root_btn.add_theme_stylebox_override("focus",  sel_style)

	if selected == null or selected == root:
		return

	# 綠色邊框標記已選節點
	if _node_buttons.has(selected):
		var sel_btn: Button = _node_buttons[selected]
		sel_btn.add_theme_stylebox_override("normal", sel_style)
		sel_btn.add_theme_stylebox_override("hover",  sel_style)
		sel_btn.add_theme_stylebox_override("focus",  sel_style)

	# 禁用同層兄弟節點
	var parent: UpgradeTreeNode = _node_parent.get(selected)
	if parent == null:
		return
	for sibling in parent.children:
		if sibling == selected:
			continue
		if _node_buttons.has(sibling):
			var sib_btn: Button = _node_buttons[sibling]
			sib_btn.disabled = true
			sib_btn.modulate = Color(0.35, 0.35, 0.35)

# ── 進場動畫 ─────────────────────────────────────────────────────────────────

func _play_enter_anim() -> void:
	await get_tree().process_frame
	modulate.a = 0.0
	scale = Vector2(0.94, 0.94)
	var tw := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_parallel(true)
	tw.tween_property(self, "modulate:a", 1.0, 0.16)
	tw.tween_property(self, "scale", Vector2.ONE, 0.16)

# ── 關閉 ─────────────────────────────────────────────────────────────────────

func _on_close() -> void:
	SignalBus.gm_switch_state.emit("play")
	queue_free()
