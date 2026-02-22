extends PanelContainer

@onready var left_grid = $VBoxContainer/HBoxContainer/ScrollContainer/GridContainer
@onready var right_info_container = $VBoxContainer/HBoxContainer/VBoxContainer2/ScrollContainer/GridContainer
@onready var anim_sprite = $VBoxContainer/HBoxContainer/VBoxContainer2/SubViewportContainer/SubViewport/AnimatedSprite2D

var unit_gallery_dict ={}

func _ready() -> void:
	
	clear_gallery()
	load_gallery()
	on_unit_select(UnitAutoload.unit_dic["red"])


func clear_gallery():
	for i in left_grid.get_children():
		i.queue_free()

func load_gallery():
	for i in UnitAutoload.unit_dic:
		if UnitAutoload.unit_dic[i].minion_id == "s_s":
			return
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
	# 1. 更新精灵图和动画
	# Vector2.ONE 就是 Vector2(1, 1) 的优雅写法
	anim_sprite.scale = Vector2.ONE*2 * (1.0 + _minion_data.size)
	anim_sprite.speed_scale = _minion_data.speed / 50.0
	play_anime(_minion_data.minion_id + " walk")
	
	# 2. 🧹 清理旧 UI (非常关键！)
	# 在添加新属性之前，必须把上一次点击生成的 Label 全都删掉
	for child in right_info_container.get_children():
		child.queue_free()
	
	# 3. 获取数据并动态生成列表
	var dict = _minion_data.get_data_dic()
	for key in dict:
		# 🚫 过滤掉不需要显示为文字的属性 (比如贴图)
		if key == "image" or key == "animation":
			continue
			
		var con = HBoxContainer.new()
		var stat_name_label = Label.new()
		var stat_value_label = Label.new()
		
		# ✨ 美化属性名字 (例如: "max_hp" -> "Max Hp: ")
		stat_name_label.text = key.replace("_", " ").capitalize() + ":"
		# 给名字一个固定宽度，这样后面的数值就会完美对齐，不会因为名字长短而参差不齐
		stat_name_label.custom_minimum_size = Vector2(120, 0) 
		
	# 🎯 处理技能数组
		if key == "ability":
			var ability_texts = []
			for x in dict[key]:
				# 确保 x 不是空的
				if x:
					var a_name = x.ability_name if "ability_name" in x else "Unknown Ability"
					var a_desc = ""
					
					# 调用我们刚写的绝赞积木系统！
					if x.has_method("get_description"):
						a_desc = x.get_description()
						
					# 拼接单条技能："- 技能名: 描述句子"
					var final_line = "- " + a_name + ": " + a_desc
					ability_texts.append(final_line)
			
			if ability_texts.is_empty():
				stat_value_label.text = "None"
			else:
				# 用换行符 \n 把所有技能串起来，变成垂直列表
				stat_value_label.text = "\n".join(ability_texts)
				
			# ⚠️ 非常关键的 UI 设置：开启自动换行和自动扩展！
			# 因为描述句子很长，不换行的话会直接冲出屏幕
			stat_value_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			stat_value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			
			stat_value_label.custom_minimum_size = Vector2(10, 0)
			
			# 顺手确保它纵向也能自然撑开
			stat_value_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
				
		# 🎯 处理普通数值
		else:
			stat_value_label.text = str(dict[key])
			
		# 把组件组装起来
		con.add_child(stat_name_label)
		con.add_child(stat_value_label)
		right_info_container.add_child(con)




func play_anime(anime_name):
	anim_sprite.play(anime_name)
