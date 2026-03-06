extends Node

#region 1. 變量定義 (Variables)
@onready var gm = get_parent()

## 當前生效的子協議包裝對象列表 (active_hex)
var active_hex_list = []

## 玩家選擇過的主協議歷史記錄 (hex_data)
var hex_history = []
#endregion

#region 2. 生命週期 (Lifecycle)
func _ready() -> void:
	# 註冊全局信號：當單位生成時觸發相關協議
	if not SignalBus.unit_spawned.is_connected(active_unit_spawn_hex):
		SignalBus.unit_spawned.connect(active_unit_spawn_hex)
#endregion

#region 3. 協議添加與歷史管理 (Core Logic)
## 核心方法：添加主協議並自動拆解子協議
func add_main_hex(h: hex_data):
	if h == null: return
	
	# 1. 存入歷史記錄，方便 UI 追溯或存檔
	hex_history.append(h)
	
	
	# 2. 自動遍歷並添加所有正向子協議
	for p_sub in h.positive_hex_list:
		add_hex(p_sub)
	
	# 3. 自動遍歷並添加所有負面子協議
	for n_sub in h.negative_hex_list:
		add_hex(n_sub)
	
	print("Main Hex added to history: ", h.resource_path.get_file())

## 將單個子協議包裝並加入激活列表
func add_hex(h: sub_hex_data):
	if h == null: return
	var ref = active_hex.new()
	ref.data = h
	active_hex_list.append(ref)
#endregion

#region 4. 協議觸發與回調 (Triggers)
## 激活所有協議的持續/即時效果 (通常在回合開始或狀態切換時調用)
func active_all_hex():
	if active_hex_list.is_empty():
		return
	for h in active_hex_list:
		if h.data.has_method("hex_process"):
			h.data.hex_process(gm)

## 停用協議效果並清理一次性協議
func deactive_all_hex():
	if active_hex_list.is_empty():
		return
	
	var temp_l = []
	for h in active_hex_list:
		# 執行回收邏輯
		if h.data.has_method("hex_process_take_back"):
			h.data.hex_process_take_back(gm)
		
		# 記錄需要移除的一次性協議
		if h.data.one_time:
			temp_l.append(h)
			
	for h in temp_l:
		active_hex_list.erase(h)

## 當單位生成時的勾子函數
func active_unit_spawn_hex(unit):
	if active_hex_list.is_empty():
		return
	for h in active_hex_list:
		if h.data.has_method("on_unit_spawn"):
			h.data.on_unit_spawn(unit)

## 清空所有協議
func clear_hex():
	active_hex_list.clear()
	# hex_history.clear() # 根據需求決定是否同時清空歷史
#endregion
