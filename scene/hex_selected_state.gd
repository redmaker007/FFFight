extends GMstate

#region description
#1. 舞台聚焦与时间冻结 (Stage Focus & Time Freeze)
#在 enter_state 一开始，系统就对战场进行了极其严格的管控：它冻结了背景里所有已有的 Hex 的交互功能，拉下了大管家的“总电闸”（暂停了发钱和刷怪），甚至再次执行了清场。这不仅是为了防止后台逻辑报错，更是为了在视觉和体验上把玩家的注意力 100% 集中在即将弹出的选择窗口上。
#
#2. 经典的随机池抽取 (Randomized Draft Pool)
#抽取逻辑写得非常紧凑安全。它会从全局的 HexAutoload 字典中，随机且不重复地抽出最多 3 个选项。代码中通过 pick_random() 和 erase() 的组合，完美避开了玩家抽到两个一模一样选项的尴尬场面，保证了选择的多样性。随后，它将这些选项喂给了实例化出来的 UI 窗口 (hex_select_window)。
#
#3. 双刃剑式的拼图系统 (Risk & Reward Resolution)
#on_select_hex 是玩家做出决定后的结算中心。这里展现了你的 Hex 系统一个极其亮眼的设计：一个选中的 hex_data 居然同时包含了 positive_hex_list（正面增益/地块）和 negative_hex_list（负面惩罚/地块）。这意味着玩家的选择永远是“双刃剑”式的策略博弈（比如：获得了金币加成地块，但同时必须接受一个给怪物加血的地块）。选定后，这些拼图会被悉数添加到大管家的 Hex 管理器中。
#
#4. 极其干净的善后与转场 (Clean Cleanup & Transition)
#当玩家选完后，状态机会立即切入 "prep"（准备阶段）。同时，end_state 会被自动调用，它像一个尽职的保洁员：重新激活背景里的 Hex，把那个弹出的选择窗口无情销毁，并极其规范地断开了信号连接（disconnect），彻底杜绝了内存泄漏或重复触发选择的严重 Bug。
#endregion

func enter_state():
	
	gm.hs.deactive_all_hex()
	var t_hex_list =[]
	var all_hex_list = HexAutoload.hex_dic.keys()
	for i in range(min(3,all_hex_list.size())):
		var random_key = all_hex_list.pick_random()
		all_hex_list.erase(random_key)
		t_hex_list.append(HexAutoload.hex_dic[random_key])
	gm.clear_board()
	gm.group_switch_func(false)
	var h_s_w = Global.hex_select_window.instantiate()
	gm.cl.add_child(h_s_w)
	h_s_w.set_hex(t_hex_list)
	SignalBus.hex_select.connect(on_select_hex)
	

func end_state():
	gm.hs.active_all_hex()
	gm.cl.get_node("hex_select_window").queue_free()
	SignalBus.hex_select.disconnect(on_select_hex)


func on_select_hex(h:hex_data):
	for sub_h in h.positive_hex_list:
		gm.hs.add_hex(sub_h)
	for sub_h in h.negative_hex_list:
		gm.hs.add_hex(sub_h)
	gm_state_machine.switch_state("prep")
	
	pass
