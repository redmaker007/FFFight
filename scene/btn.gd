# menu_button.gd
extends Button

@onready var arrow: Label = $HBoxContainer/Arrow
@onready var label: Label = $HBoxContainer/BtnLabel
@onready var underline: ColorRect = $HBoxContainer/Underline

const COLOR_NORMAL = Color("#6b7280")
const COLOR_HOVER  = Color("#e8c84a")
const OFFSET_X = 6.0 
const MAX_UNDERLINE_WIDTH = 280.0 # 將數值抽出來方便管理

var arrow_origin_x: float
var active_tween: Tween # 新增：記錄當前正在執行的 Tween

func _ready():
	mouse_entered.connect(_on_hover)
	mouse_exited.connect(_on_exit)
	arrow_origin_x = arrow.position.x
	underline.size.x = 0

func _on_hover():
	# 關鍵修正：如果舊動畫還在跑，直接殺掉它
	if active_tween:
		active_tween.kill()
	
	active_tween = create_tween().set_parallel(true)
	
	# 顏色切換
	active_tween.tween_property(self, "theme_override_colors/font_color", COLOR_HOVER, 0.15)
	
	# 底線伸長：使用絕對目標值 MAX_UNDERLINE_WIDTH
	active_tween.tween_property(underline, "size:x", MAX_UNDERLINE_WIDTH, 0.25)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# 箭頭移動：使用絕對目標值
	active_tween.tween_property(arrow, "position:x", arrow_origin_x + OFFSET_X, 0.15)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _on_exit():
	# 同樣先殺掉舊動畫
	if active_tween:
		active_tween.kill()
		
	active_tween = create_tween().set_parallel(true)
	
	# 恢復顏色
	active_tween.tween_property(self, "theme_override_colors/font_color", COLOR_NORMAL, 0.15)
	
	# 底線收回：目標絕對是 0
	active_tween.tween_property(underline, "size:x", 0.0, 0.2)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	# 箭頭歸位
	active_tween.tween_property(arrow, "position:x", arrow_origin_x, 0.15)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
