extends PanelContainer

# ===== 数据 =====
var h: hex_data

# ===== 字体大小 =====
@export var font_size_hex_name: int = 16
@export var font_size_pos_des: int = 13
@export var font_size_neg_des: int = 13
@export var font_size_and: int = 11
@export var font_size_button: int = 13

# ===== 粒子参数 - B级 =====
@export_group("Particles B")
@export var b_amount: int = 8
@export var b_lifetime: float = 2.0
@export var b_vel_min: float = 10.0
@export var b_vel_max: float = 25.0
@export var b_scale_min: float = 0.5
@export var b_scale_max: float = 1.2
@export var b_gravity: float = -20.0

# ===== 粒子参数 - A级 =====
@export_group("Particles A")
@export var a_amount: int = 15
@export var a_lifetime: float = 1.2
@export var a_vel_min: float = 30.0
@export var a_vel_max: float = 70.0
@export var a_scale_min: float = 0.8
@export var a_scale_max: float = 2.0
@export var a_gravity: float = -60.0

# ===== 粒子参数 - S级 =====
@export_group("Particles S")
@export var s_amount: int = 25
@export var s_lifetime: float = 1.5
@export var s_vel_min: float = 40.0
@export var s_vel_max: float = 100.0
@export var s_scale_min: float = 0.5
@export var s_scale_max: float = 1.5
@export var s_gravity: float = -80.0

# ===== 粒子参数 - D级 =====
@export_group("Particles D")
@export var d_amount: int = 35
@export var d_lifetime: float = 3.0
@export var d_vel_min: float = 20.0
@export var d_vel_max: float = 60.0
@export var d_scale_min: float = 1.5
@export var d_scale_max: float = 3.0
@export var d_gravity: float = 30.0

# ===== 光晕参数 =====
@export_group("Glow")
@export var glow_size_min: float = 4.0
@export var glow_size_max: float = 16.0
@export var glow_alpha_min: float = 0.2
@export var glow_alpha_max: float = 0.6
@export var glow_duration: float = 1.2

# ===== 节点引用 =====
@onready var hex_name_label = %hex_name
@onready var particles = $GPUParticles2D
@onready var label_3: Label = $VBoxContainer/Label3

# ===== 稀有度配置 =====
const RARITY_CONFIG = {
	"S": {"color": Color("ffcc00")},
	"D": {"color": Color("8b0000")},
	"A": {"color": Color("ff4500")},
	"B": {"color": Color("4a90e2")},
	"C": {"color": Color("7f7f7f")},
}

# ===== 内部状态 =====
var glow_tween: Tween
# ===== 闪卡参数 =====
@export_group("Hover Flash")
@export var flash_scale: float = 1.04
@export var flash_duration: float = 0.12
@export var flash_peak_alpha: float = 0.22

@onready var btn = %button
@onready var flash_rect: ColorRect = %ColorRect

var flash_tween: Tween
# ==================================================
# 初始化
# ==================================================
func _ready() -> void:
	var r_key = h.hex_rarity if h and h.hex_rarity != null else "C"

	# 初始化 flash_rect：白色，起始完全透明
	flash_rect.color = Color(1, 1, 1, 1)
	flash_rect.modulate.a = 0.0

	_apply_visual_style(r_key)
	_setup_labels()
	_setup_button(r_key)
	_start_glow_animation(r_key)
	_fit_particles_to_panel()

	
	btn.mouse_entered.connect(_on_mouse_entered)
	btn.mouse_exited.connect(_on_mouse_exited)

# ==================================================
# UI 设置
# ==================================================
func _setup_labels() -> void:
	var lab1 = $VBoxContainer/Label
	var lab2 = $VBoxContainer/Label2

	label_3.text = tr("AND")
	label_3.add_theme_font_size_override("font_size", font_size_and)

	hex_name_label.text = h.get_name_text()
	hex_name_label.add_theme_font_size_override("font_size", font_size_hex_name)

	lab1.text = "> " + h.get_pos_des()
	lab1.add_theme_color_override("font_color", Color("4ae891"))
	lab1.add_theme_font_size_override("font_size", font_size_pos_des)

	lab2.text = "> " + h.get_neg_des()
	lab2.add_theme_color_override("font_color", Color("e84a4a"))
	lab2.add_theme_font_size_override("font_size", font_size_neg_des)

func _setup_button(rarity: String) -> void:
	
	var theme_color = RARITY_CONFIG.get(rarity, RARITY_CONFIG["C"])["color"]

	#btn.text = ""
	#btn.add_theme_color_override("font_color", theme_color)
	#btn.add_theme_font_size_override("font_size", font_size_button)
	btn.pressed.connect(hex_select)
#
	#var normal_style = StyleBoxFlat.new()
	#normal_style.bg_color = Color(0, 0, 0, 0)
	#normal_style.border_color = theme_color
	#normal_style.set_border_width_all(1)
	#btn.add_theme_stylebox_override("normal", normal_style)
#
	#var hover_style = StyleBoxFlat.new()
	#hover_style.bg_color = theme_color
	#btn.add_theme_stylebox_override("hover", hover_style)
#
	#btn.add_theme_color_override("font_hover_color",
		#Color.BLACK if rarity in ["S", "D"] else Color.WHITE)
		
func _on_mouse_entered() -> void:
	if flash_tween:
		flash_tween.kill()
	flash_tween = create_tween().set_parallel(true)
	flash_tween.tween_property(self, "scale", Vector2.ONE * flash_scale, 0.1)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	flash_tween.tween_property(flash_rect, "modulate:a", flash_peak_alpha, flash_duration * 0.4)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _on_mouse_exited() -> void:
	if flash_tween:
		flash_tween.kill()
	# 同时缩回 + 确保 flash_rect 归零（无论中断在哪个阶段）
	flash_tween = create_tween().set_parallel(true)
	flash_tween.tween_property(self, "scale", Vector2.ONE, 0.1)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	flash_tween.tween_property(flash_rect, "modulate:a", 0.0, 0.1)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
# ==================================================
# 视觉特效
# ==================================================
func _apply_visual_style(rarity: String) -> void:
	var theme_color = RARITY_CONFIG.get(rarity, RARITY_CONFIG["C"])["color"]

	var style = StyleBoxFlat.new()
	style.bg_color = Color("0d1520")
	style.set_border_width_all(1)
	style.border_width_top = 4
	style.border_color = theme_color
	if rarity in ["S", "D"]:
		style.shadow_color = theme_color
		style.shadow_color.a = 0.4
		style.shadow_size = 12
		if rarity == "D":
			style.border_blend = true
	add_theme_stylebox_override("panel", style)

	if not particles:
		return
	var mat = particles.process_material
	if not mat is ParticleProcessMaterial:
		return

	match rarity:
		"C":
			particles.emitting = false
		"B":
			particles.emitting = true
			particles.amount   = b_amount
			particles.lifetime = b_lifetime
			mat.color                = Color("4a90e2")
			mat.initial_velocity_min = b_vel_min
			mat.initial_velocity_max = b_vel_max
			mat.scale_min            = b_scale_min
			mat.scale_max            = b_scale_max
			mat.gravity              = Vector3(0, b_gravity, 0)
			mat.hue_variation_min    = -0.05
			mat.hue_variation_max    = 0.05
		"A":
			particles.emitting = true
			particles.amount   = a_amount
			particles.lifetime = a_lifetime
			mat.color                = Color("ff4500")
			mat.initial_velocity_min = a_vel_min
			mat.initial_velocity_max = a_vel_max
			mat.scale_min            = a_scale_min
			mat.scale_max            = a_scale_max
			mat.gravity              = Vector3(0, a_gravity, 0)
			mat.hue_variation_min    = -0.03
			mat.hue_variation_max    = 0.03
		"S":
			particles.emitting = true
			particles.amount   = s_amount
			particles.lifetime = s_lifetime
			mat.color                = Color("ffcc00")
			mat.initial_velocity_min = s_vel_min
			mat.initial_velocity_max = s_vel_max
			mat.scale_min            = s_scale_min
			mat.scale_max            = s_scale_max
			mat.gravity              = Vector3(0, s_gravity, 0)
			mat.hue_variation_min    = -0.05
			mat.hue_variation_max    = 0.05
		"D":
			particles.emitting = true
			particles.amount   = d_amount
			particles.lifetime = d_lifetime
			mat.color                = Color("8b0000")
			mat.initial_velocity_min = d_vel_min
			mat.initial_velocity_max = d_vel_max
			mat.scale_min            = d_scale_min
			mat.scale_max            = d_scale_max
			mat.gravity              = Vector3(0, d_gravity, 0)
			mat.hue_variation_min    = 0.0
			mat.hue_variation_max    = 0.0

func _start_glow_animation(rarity: String) -> void:
	if rarity == "C":
		return
	var theme_color = RARITY_CONFIG.get(rarity, RARITY_CONFIG["C"])["color"]

	if glow_tween:
		glow_tween.kill()
	glow_tween = create_tween().set_loops()

	var style = get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	var update = func(v: float):
		style.shadow_size  = v
		style.shadow_color = theme_color
		style.shadow_color.a = remap(v, glow_size_min, glow_size_max, glow_alpha_min, glow_alpha_max)
		add_theme_stylebox_override("panel", style)

	glow_tween.tween_method(update, glow_size_min, glow_size_max, glow_duration)
	glow_tween.tween_method(update, glow_size_max, glow_size_min, glow_duration)

func _fit_particles_to_panel() -> void:
	if not particles:
		return
	var mat = particles.process_material
	if not mat is ParticleProcessMaterial:
		return
	await get_tree().process_frame
	var s = size
	mat.emission_shape       = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	mat.emission_box_extents = Vector3(s.x / 2.0, s.y / 2.0, 0)
	particles.position       = Vector2(s.x / 2.0, s.y / 2.0)

# ==================================================
# 事件
# ==================================================
func hex_select() -> void:
	SignalBus.hex_select.emit(h)
