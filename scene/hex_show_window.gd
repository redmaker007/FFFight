extends PanelContainer

#region 1. 常量與顏色配置 (Constants & Rarity)
# 從主模塊繼承稀有度顏色
const RARITY_CONFIG = {
	"S": {"color": Color("ffcc00")}, # 金色
	"D": {"color": Color("8b0000")}, # 暗紅
	"A": {"color": Color("ff4500")}, # 橙色
	"B": {"color": Color("4a90e2")}, # 藍色
	"C": {"color": Color("7f7f7f")}, # 灰色
}
#endregion

#region 2. 節點引用 (Onready Variables)
@onready var good_container = $VBoxContainer/ScrollContainer/HBoxContainer/GoodContainer
@onready var bad_container = $VBoxContainer/ScrollContainer/HBoxContainer/BadContainer
@onready var back_button = $VBoxContainer/Button
#endregion

#region 3. 生命周期 (Lifecycle)
func _ready() -> void:
	_apply_window_style()
	_connect_signals()
	_render_active_protocols()
#endregion

#region 4. 初始化設置 (Initialization)
func _apply_window_style():
	var style = StyleBoxFlat.new()
	style.bg_color = Color("0d1520f2") # 深色半透明
	style.set_border_width_all(2)
	style.border_color = Color("1e2a3a")
	add_theme_stylebox_override("panel", style)

func _connect_signals():
	if not back_button.pressed.is_connected(_on_close):
		back_button.pressed.connect(_on_close)
	
	back_button.mouse_entered.connect(_on_button_hover.bind(true))
	back_button.mouse_exited.connect(_on_button_hover.bind(false))
	back_button.text = tr("BACK_TO_BATTLE")
#endregion

#region 5. 協議渲染邏輯 (Protocol Rendering)
func _render_active_protocols():
	var gm = get_tree().root.get_child(get_tree().root.get_child_count() - 1)
	if not gm or not gm.hs: return

	# 1. 清空舊容器
	for child in good_container.get_children(): child.queue_free()
	for child in bad_container.get_children(): child.queue_free()

	# 2. 建立當前仍生效的 sub_hex_data 集合（過濾已清掉的 one_time sub）
	var active_subs = {}
	for h in gm.hs.active_hex_list:
		active_subs[h.data] = true

	# 3. 遍歷 hex_history，每個主協議建一條描述條目
	for h_data in gm.hs.hex_history:

		if not h_data: continue

		var rarity_key = str(h_data.hex_rarity).to_upper()
		# 正面：只要有任意一個 sub 仍生效就顯示主協議正面描述
		var show_pos = false
		for sub in h_data.positive_hex_list:
			
			if not sub.one_time or active_subs.has(sub):
				show_pos = true
				break
		if show_pos:
			_create_entry(h_data.get_pos_des(), rarity_key, good_container, true)
		# 負面：同上
		var show_neg = false
		for sub in h_data.negative_hex_list:
			
			if not sub.one_time or active_subs.has(sub):
				show_neg = true
				break
		if show_neg:
			_create_entry(h_data.get_neg_des(), rarity_key, bad_container, false)
func _create_entry(description: String, rarity_key: String, container: Control, is_positive: bool):
	var entry = PanelContainer.new()
	var v_box = VBoxContainer.new()
	entry.add_child(v_box)
	entry.custom_minimum_size = Vector2(0,100)
	container.add_child(entry)

	# 根據主模塊稀有度獲取顏色
	var config = RARITY_CONFIG.get(rarity_key, RARITY_CONFIG["C"])
	var theme_color = config["color"]

	# --- 條目樣式 ---
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.1, 0.5)
	style.set_border_width_all(1)


	# 正面色條在左，負面在右
	if is_positive:
		style.border_width_left = 4
	else:
		style.border_width_right = 4
	style.border_color = theme_color
	entry.add_theme_stylebox_override("panel", style)

	# --- 內容文本 ---
	var desc_label = Label.new()

	desc_label.text = "✦ " + description
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.add_theme_font_size_override("font_size", 20)
	
	var type_label = Label.new()
	# 顯示稀有度前綴，例如 "S PROTOCOL"
	type_label.text = rarity_key + " " + tr("PROTOCOL")
	type_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT if is_positive else HORIZONTAL_ALIGNMENT_LEFT
	type_label.modulate = theme_color
	type_label.modulate.a = 0.6
	type_label.add_theme_font_size_override("font_size", 10)
	
	v_box.add_child(desc_label)
	v_box.add_child(type_label)
	
	# --- 動畫 ---
	entry.modulate.a = 0
	entry.scale = Vector2(0.98, 0.98)
	var tw = create_tween().set_parallel(true)
	tw.tween_property(entry, "modulate:a", 1.0, 0.15)
	tw.tween_property(entry, "scale", Vector2.ONE, 0.15)
#endregion

#region 6. 信號與動畫 (Signals & Tweens)
func _on_button_hover(is_hover: bool):
	var tw = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	if is_hover:
		tw.tween_property(back_button, "custom_minimum_size:x", 240, 0.2)
		tw.parallel().tween_property(back_button, "modulate", Color(1.3, 1.3, 1.3), 0.2)
	else:
		tw.tween_property(back_button, "custom_minimum_size:x", 200, 0.2)
		tw.parallel().tween_property(back_button, "modulate", Color.WHITE, 0.2)

func _on_close() -> void:
	#var tw = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	##tw.tween_property(self, "scale", Vector2(0.9, 0.9), 0.15)
	##tw.parallel().tween_property(self, "modulate:a", 0.0, 0.15)
	##await tw.finished
	
	SignalBus.gm_switch_state.emit("play")
	queue_free()
#endregion
