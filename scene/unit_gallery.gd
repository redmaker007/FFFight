extends PanelContainer

@onready var left_grid = $VBoxContainer/HBoxContainer/ScrollContainer/GridContainer
@onready var right_info_container = $VBoxContainer/HBoxContainer/VBoxContainer2/ScrollContainer/GridContainer
@onready var anim_sprite = $VBoxContainer/HBoxContainer/VBoxContainer2/SubViewportContainer/SubViewport/AnimatedSprite2D

# ===== 字体大小设置 =====
@export var font_size_unit_name: int = 28
@export var font_size_stat_key: int = 13
@export var font_size_stat_value: int = 15
@export var font_size_abilities_title: int = 11
@export var font_size_ability_name: int = 12
@export var font_size_ability_desc: int = 11
# =======================

var unit_gallery_dict ={}

func _ready() -> void:
	Global.slide_in(self,40.0)
	clear_gallery()
	load_gallery()
	on_unit_select(UnitAutoload.unit_dic["red"])


func clear_gallery():
	for i in left_grid.get_children():
		i.queue_free()

func load_gallery():
	
	for i in UnitAutoload.unit_dic:
		
		if UnitAutoload.unit_dic[i].minion_id in ["s_s","base"] :
			continue
		var unit_butt = TextureButton.new()
		unit_butt.texture_normal = UnitAutoload.unit_dic[i].image
		unit_butt.ignore_texture_size = true
		unit_butt.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		unit_butt.custom_minimum_size = Vector2(200,200)
		
		unit_butt.pressed.connect(on_unit_select.bind(UnitAutoload.unit_dic[i]))
		left_grid.add_child(unit_butt)


func _on_button_pressed() -> void:
	SignalBus.gm_switch_state.emit("play")
	queue_free()

func on_unit_select(_minion_data):
	anim_sprite.scale = Vector2.ONE * 2 * (1.0 + _minion_data.size) * 0.4
	anim_sprite.speed_scale = _minion_data.speed / 50.0
	play_anime(_minion_data.minion_id + " walk")

	for child in right_info_container.get_children():
		child.queue_free()

	var name_label = Label.new()
	name_label.text = _minion_data.get_name_key()
	name_label.add_theme_color_override("font_color", Color("#e8c84a"))
	name_label.add_theme_font_size_override("font_size", font_size_unit_name)
	name_label.add_theme_constant_override("outline_size", 0)
	right_info_container.add_child(name_label)

	var sep = HSeparator.new()
	sep.add_theme_color_override("separator", Color("#e8c84a", 0.3))
	sep.custom_minimum_size = Vector2(0, 12)
	right_info_container.add_child(sep)

	var dict = _minion_data.get_data_dic()

	var stat_display = {
		"max_hp":    tr("STAT_HP"),
		"att":       tr("STAT_ATK"),
		"att_spd":   tr("STAT_ATK_SPD"),
		"att_r":     tr("STAT_RANGE"),
		"speed":     tr("STAT_SPEED"),
		"deploy_cd": tr("STAT_DEPLOY_CD"),
		"cost":      tr("STAT_COST"),
		"size":      tr("STAT_SIZE"),
	}

	for key in stat_display:
		if not key in dict:
			continue
		var value_str: String
		if key == "deploy_cd":
			value_str = str(dict[key]) + "s"
		elif key == "att_spd":
			value_str = str(dict[key]) + "/s"
		elif key == "att_r":
			value_str = str(dict[key]) + " u"
		elif key == "cost":
			value_str = "$" + str(dict[key])
		else:
			value_str = str(dict[key])
		_add_stat_row(right_info_container, stat_display[key], value_str)

	if "ability" in dict and not dict["ability"].is_empty():
		var ab_sep = HSeparator.new()
		ab_sep.add_theme_color_override("separator", Color("#4a5568"))
		ab_sep.custom_minimum_size = Vector2(0, 8)
		right_info_container.add_child(ab_sep)

		var ab_title = Label.new()
		ab_title.text = tr("ABILITIES")
		ab_title.add_theme_color_override("font_color", Color("#6b7280"))
		ab_title.add_theme_font_size_override("font_size", font_size_abilities_title)
		right_info_container.add_child(ab_title)

		for x in dict["ability"]:
			if not x:
				continue
			var a_name = x.get_ability_name()
			var a_desc = x.get_description()
			_add_ability_row(right_info_container, a_name, a_desc)


func _add_stat_row(container: Node, label_text: String, value_text: String):
	var row = HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 28)

	var key_label = Label.new()
	key_label.text = label_text
	key_label.custom_minimum_size = Vector2(100, 0)
	key_label.add_theme_color_override("font_color", Color("#4a5568"))
	key_label.add_theme_font_size_override("font_size", font_size_stat_key)
	key_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	var sep_label = Label.new()
	sep_label.text = ">"
	sep_label.add_theme_color_override("font_color", Color("#2d3748"))
	sep_label.add_theme_font_size_override("font_size", font_size_stat_key)
	sep_label.custom_minimum_size = Vector2(20, 0)
	sep_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	var val_label = Label.new()
	val_label.text = value_text
	val_label.add_theme_color_override("font_color", Color("#e8e8e8"))
	val_label.add_theme_font_size_override("font_size", font_size_stat_value)
	val_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	val_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	row.add_child(key_label)
	row.add_child(sep_label)
	row.add_child(val_label)
	container.add_child(row)

func _add_ability_row(container: Node, ab_name: String, ab_desc: String):
	var col = VBoxContainer.new()
	col.custom_minimum_size = Vector2(0, 0)

	var name_l = Label.new()
	name_l.text = "· " + ab_name.to_upper()
	name_l.add_theme_color_override("font_color", Color("#e8c84a", 0.8))
	name_l.add_theme_font_size_override("font_size", font_size_ability_name)
	col.add_child(name_l)

	if ab_desc != "":
		var desc_l = Label.new()
		desc_l.text = "  " + ab_desc
		desc_l.add_theme_color_override("font_color", Color("#6b7280"))
		desc_l.add_theme_font_size_override("font_size", font_size_ability_desc)
		desc_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		col.add_child(desc_l)

	container.add_child(col)


func play_anime(anime_name):
	anim_sprite.play(anime_name)
	
