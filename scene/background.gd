# background.gd
# 挂在 background 节点上

extends Node2D

@onready var sky: TextureRect = $sky
@onready var mountain: Sprite2D = $mountain
@onready var ground: ColorRect = $ground
@onready var road: Sprite2D = $road
@onready var sun_moon: Sprite2D = $sun_moon
@onready var particle: GPUParticles2D = %particle

const THEMES = [
	{   # 主题0 · 晴天正午
		"sky_top":      Color("#5b8fc9"),
		"sky_bottom":   Color("#a8cff0"),
		"mountain":     Color("#3a6b8a"),
		"ground":       Color("#6b8f4e"),
		"sun_color":    Color("#f5e642"),
		"sun_pos":      Vector2(200, 80),
	},
	{   # 主题1 · 黄昏橙红
		"sky_top":      Color("#1a1a3e"),
		"sky_bottom":   Color("#e8643a"),
		"mountain":     Color("#2d1f3d"),
		"ground":       Color("#7a5c3a"),
		"sun_color":    Color("#ff8c00"),
		"sun_pos":      Vector2(200, 160),
	},
	{   # 主题2 · 夜晚
		"sky_top":      Color("#050810"),
		"sky_bottom":   Color("#0f1a3a"),
		"mountain":     Color("#0a0f1f"),
		"ground":       Color("#1f2d1f"),
		"sun_color":    Color("#e8e0c8"),
		"sun_pos":      Vector2(200, 100),
	},
	{   # 主题3 · 暴风雪
		"sky_top":      Color("#3a3f4a"),
		"sky_bottom":   Color("#8a9aaa"),
		"mountain":     Color("#2a3040"),
		"ground":       Color("#d0dce8"),
		"sun_color":    Color("#c0c8d0"),
		"sun_pos":      Vector2(200, 80),
	},
]

var current_theme_index: int = 0
var sky_gradient: Gradient

func _ready() -> void:
	# 初始化天空渐变
	sky_gradient = sky.texture.gradient
	_apply_theme(THEMES[0], false)
	
	# 监听波次信号
	SignalBus.bg_theme_change.connect(_on_bg_theme_change)

func _on_bg_theme_change(theme_index: int) -> void:
	var idx = theme_index % THEMES.size()
	if idx == current_theme_index:
		return
	current_theme_index = idx
	_apply_theme(THEMES[idx], true)

func _apply_theme(theme: Dictionary, animated: bool) -> void:
	if not animated:
		sky_gradient.set_color(0, theme.sky_top)
		sky_gradient.set_color(1, theme.sky_bottom)
		mountain.modulate = theme.mountain
		ground.color = theme.ground
		sun_moon.modulate = theme.sun_color
		sun_moon.position = theme.sun_pos
		return

	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)

	# 天空渐变两端颜色
	tween.tween_method(
		func(c): sky_gradient.set_color(0, c),
		sky_gradient.get_color(0), theme.sky_top, 3.0
	)
	tween.tween_method(
		func(c): sky_gradient.set_color(1, c),
		sky_gradient.get_color(1), theme.sky_bottom, 3.0
	)

	# 其他节点
	tween.tween_property(mountain, "modulate", theme.mountain, 3.0)
	tween.tween_property(ground, "color", theme.ground, 3.0)
	tween.tween_property(sun_moon, "modulate", theme.sun_color, 3.0)
	tween.tween_property(sun_moon, "position", theme.sun_pos, 3.0)
