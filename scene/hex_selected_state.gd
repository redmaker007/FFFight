# GMstate_Hex.gd
extends GMstate

#region 1. 進入狀態 (Enter State)
func enter_state():
	# 1. 基礎環境凍結
	gm.hs.deactive_all_hex()
	gm.group_switch_func(false)
	gm.clear_board()
	
	# 2. 抽取協議 (使用 Autoload 權重接口)
	var t_hex_list = HexAutoload.draw_hex_multiple(3)
	
	# 3. UI 實例化與數據初始化
	var h_s_w = Global.hex_select_window.instantiate()
	h_s_w.name = "hex_select_window" # 給個名字方便 end_state 查找
	gm.cl.add_child(h_s_w)
	h_s_w.set_hex(t_hex_list)
	
	# 4. 監聽選擇信號
	if not SignalBus.hex_select.is_connected(on_select_hex):
		SignalBus.hex_select.connect(on_select_hex)
#endregion

#region 2. 邏輯回調 (Logic Callbacks)
func on_select_hex(h: hex_data):
	if h == null: return
	
	# --- 修改處：直接調用系統封裝好的 add_main_hex ---
	# 這會自動完成：1.加入歷史 2.拆解正向子協議 3.拆解負面子協議
	gm.hs.add_main_hex(h)
	# ----------------------------------------------
	
	# 選擇完畢，進入商店
	gm_state_machine.switch_state("shop")
#endregion

#region 3. 結束與清理 (Exit & Cleanup)
func end_state():
	# 1. 激活所有當前生效的協議效果
	gm.hs.active_all_hex()
	
	# 2. 清理 UI 窗口
	var window = gm.cl.get_node_or_null("hex_select_window")
	if window: 
		window.queue_free()
		
	# 3. 斷開信號連接（防止重複觸發）
	if SignalBus.hex_select.is_connected(on_select_hex):
		SignalBus.hex_select.disconnect(on_select_hex)
#endregion
