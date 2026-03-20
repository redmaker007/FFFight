extends Control


@onready var title_label = $VBoxContainer/Panel/VBox/Title
@onready var sub_label = $VBoxContainer/Panel/VBox/Subtitle
@onready var wave_label = $VBoxContainer/Panel/VBox/Stats/WaveNum
@onready var money_label = $VBoxContainer/Panel/VBox/Stats/MoneyNum
@onready var hp_label = $VBoxContainer/Panel/VBox/Stats/HPNum
@onready var retry_btn = $VBoxContainer/Panel/VBox/Buttons/RetryBtn
@onready var menu_btn = $VBoxContainer/Panel/VBox/Buttons/MenuBtn
@onready var bg_panel = $VBoxContainer/Panel

func _ready():
	visible = false
	retry_btn.pressed.connect(on_retry)
	menu_btn.pressed.connect(on_menu)

func show_result(win: bool, wave: int, money: int, hp_pct: float):
	visible = true
	
	if win:
		title_label.text = tr("RESULT_VICTORY")
		title_label.add_theme_color_override("font_color", Color("e8c84a"))
		sub_label.text = tr("RESULT_VICTORY_SUB")
	else:
		title_label.text = tr("RESULT_DEFEATED")
		title_label.add_theme_color_override("font_color", Color("e84a4a"))
		sub_label.text = tr("RESULT_DEFEATED_SUB")

	wave_label.text = tr("RESULT_WAVE_COUNT") % wave
	money_label.text = tr("RESULT_MONEY_COUNT") % money
	hp_label.text = tr("RESULT_HP_PCT") % int(hp_pct * 100)
	
	bg_panel.modulate.a = 0
	bg_panel.position.y = 2000  # 先把面板移到屏幕下方

	var tw = create_tween()
	tw.set_parallel(true)  # 所有动画同时播
	tw.tween_property(bg_panel, "modulate:a", 1.0, 0.4)
	tw.tween_property(bg_panel, "position:y", 150, 0.3)\
	  .set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func on_retry():
	visible = false
	SignalBus.emit_signal("gm_switch_state", "init")

func on_menu():
	visible = false
	get_tree().change_scene_to_file("res://scene/main_menu.tscn")
