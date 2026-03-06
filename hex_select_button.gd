extends PanelContainer

var h: hex_data
var lab1
var lab2

# 稀有度視覺配置
# 重新定義稀有度顏色與粒子強度
const RARITY_CONFIG = {
	"S": {"color": Color("ffcc00"), "particles": 25, "energy": 2.0}, # 傳奇：閃耀金
	"D": {"color": Color("8b0000"), "particles": 35, "energy": 2.5}, # 惡魔：暗紅 (粒子最多)
	"A": {"color": Color("ff4500"), "particles": 15, "energy": 1.5}, # 極稀有：橙色
	"B": {"color": Color("4a90e2"), "particles": 8,  "energy": 1.2}, # 稀有：藍色
	"C": {"color": Color("7f7f7f"), "particles": 0,  "energy": 1.0}, # 普通：灰色
}

@onready var hex_name_label = $VBoxContainer/hex_name
@onready var particles = $GPUParticles2D # 請在場景中添加此節點

func _ready() -> void:
	# 1. 獲取稀有度字串 (假設 Enum 的名稱是 S, D, A, B, C)
	var r_key = "C"
	if h and h.hex_rarity != null:
		# 將 Enum 索引轉為字串，或直接讀取屬性
		r_key = str(h.hex_rarity).to_upper() 

	# 2. 應用面板與粒子樣式
	_apply_visual_style(r_key)
	
	# 3. 按鈕與文字邏輯 (含 tr 翻譯)
	var button = $HBoxContainer/button
	button.pressed.connect(hex_select)
	_style_select_button(button, r_key)
	
	lab1 = $VBoxContainer/Label
	lab2 = $VBoxContainer/Label2
	
	# 名稱翻譯與格式化
	var display_name = tr(h.hex_name)
	if display_name == h.hex_name:
		display_name = h.hex_name.replace("_", " ").capitalize()
	hex_name_label.text = display_name
	
	# 效果描述翻譯
	lab1.text = "✦ " + tr(h.get_pos_des())
	lab1.add_theme_color_override("font_color", Color("4ae891"))
	
	lab2.text = "✦ " + tr(h.get_neg_des())
	lab2.add_theme_color_override("font_color", Color("e84a4a"))

func _apply_visual_style(rarity: String):
	var config = RARITY_CONFIG.get(rarity, RARITY_CONFIG["C"])
	var theme_color = config["color"]
	
	# --- A. 面板(self) 樣式設置 ---
	var style = StyleBoxFlat.new()
	style.bg_color = Color("0d1520") # 深色背景基調
	style.set_border_width_all(1)
	style.border_width_top = 4       # 頂部邊框加厚
	style.border_color = theme_color
	
	# S 級(金) 和 D 級(暗紅) 增加外發光陰影
	if rarity == "S" or rarity == "D":
		style.shadow_color = theme_color
		style.shadow_color.a = 0.4
		style.shadow_size = 12
		# 惡魔級(D) 讓邊框稍微帶點髒髒的感覺(黑色混合)
		if rarity == "D":
			style.border_blend = true
	
	add_theme_stylebox_override("panel", style)
	
	# --- B. 粒子效果設置 ---
	if particles:
		particles.emitting = config["particles"] > 0
		particles.amount = config["particles"]
		
		# 獲取粒子材質 (假設是 ParticleProcessMaterial)
		var mat = particles.process_material
		if mat is ParticleProcessMaterial:
			mat.color = theme_color
			
			# D 級(惡魔) 的粒子行為特徵：更重、更慢、更壓抑
			if rarity == "D":
				mat.initial_velocity_min = 20
				mat.initial_velocity_max = 60
				mat.scale_min = 1.5
				mat.scale_max = 3.0
			# S 級(金色) 的粒子行為特徵：輕盈、快速閃爍
			elif rarity == "S":
				mat.initial_velocity_min = 40
				mat.initial_velocity_max = 100
				mat.hue_variation_min = -0.05
				mat.hue_variation_max = 0.05

func _style_select_button(btn: Button, rarity: String):
	var theme_color = RARITY_CONFIG.get(rarity, RARITY_CONFIG["C"])["color"]
	
	btn.text = tr("choose") # 多語言支持
	btn.add_theme_color_override("font_color", theme_color)
	
	# 設置按鈕邊框
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = Color(0, 0, 0, 0)
	normal_style.border_color = theme_color
	normal_style.set_border_width_all(1)
	btn.add_theme_stylebox_override("normal", normal_style)
	
	# 懸停效果
	var hover_style = StyleBoxFlat.new()
	hover_style.bg_color = theme_color
	btn.add_theme_stylebox_override("hover", hover_style)
	
	# 如果是 S 級或 D 級，按鈕懸停時文字變黑反白效果更好
	if rarity == "S" or rarity == "D":
		btn.add_theme_color_override("font_hover_color", Color.BLACK)
	else:
		btn.add_theme_color_override("font_hover_color", Color.WHITE)
func hex_select():
	SignalBus.hex_select.emit(h)
