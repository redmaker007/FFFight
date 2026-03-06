extends Node

#region 1. 變量與配置 (Properties & Variables)
@export var spec_unit: String
# --- 新增配置 ---
@export var constant_spawn_cd: float = 7.0 # 恆定的刷怪間隔
@export var burst_interval: float = 0.1 # 連刷小間隔（個體間隔）
# ----------------

@onready var GM = get_parent()
@onready var wave_number_label = GM.wave_number_label 

var pool = ["red", "blue", "boxer", "snow_b_s", "bf_k"]
var functioning: bool = false

var spawn_CD: float = 0                       # 主計時器
var burst_spawn_CD: float = 0                 # 連刷計時器
var is_bursting: bool = false
var count: int = 0
var theme: int = 0


# 模式說明：
# mode 1: {"mode": 1, "unit": "red", "amount": 5}
# mode 2: {"mode": 2, "pool": ["red", "blue"], "amount": 3}
var level_wave_array: Array = [] 
var current_wave_queue: Array = [] # 存放當前波次拆解後的單個敵人隊列
# --------------------------
#endregion

#region 2. 生命周期 (Lifecycle)
func _ready() -> void:
	await get_tree().process_frame
	GM = get_parent()
	wave_number_label = GM.wave_number_label
	
	# --- 初始化測試數據 (實際使用時可從外部 JSON 或 Resource 載入) ---
	setup_test_level()
	# -------------------------------------------------------
	
	count = 0
	update_wave_number_label()

func _process(delta: float) -> void:
	if not functioning:
		return
		
	# --- A. 波次觸發邏輯 (大循環) ---
	if not is_bursting:
		if spawn_CD >= constant_spawn_cd:
			# 只有當連刷隊列空了，才去加載 level_wave_array 的下一筆 (包括你插隊的那一筆)
			if current_wave_queue.is_empty() and not level_wave_array.is_empty():
				prepare_next_wave()
				
				# 加載完後，如果隊列有東西，啟動連刷
				if not current_wave_queue.is_empty():
					is_bursting = true
					burst_spawn_CD = burst_interval # 第一隻怪觸發
					spawn_CD = 0 # 重置 7 秒計時
		else:
			spawn_CD += delta
			
	# --- B. 連刷處理邏輯 (小循環) ---
	if is_bursting:
		if burst_spawn_CD >= burst_interval:
			if not current_wave_queue.is_empty():
				# 刷出一隻怪
				var next_unit = current_wave_queue.pop_front()
				spawn_enemy_1(next_unit)
				count += 1
				update_wave_number_label()
				
				# 主題更換檢查
				if count % 10 == 0:
					theme += 1
					SignalBus.bg_theme_change.emit(theme % 4)
				
				burst_spawn_CD = 0 # 重置連刷計時
			else:
				# 隊列清空，結束連刷狀態，回到主計時循環
				is_bursting = false
		else:
			burst_spawn_CD += delta
#endregion

#region 3. 核心控制 (Core Controls)



func reset_whole():
	count = 0
	spawn_CD = 0
	current_wave_queue.clear()
#endregion

#region 4. 刷怪邏輯 (Spawn Logic)

# --- 新增：解析 WaveData 並填充到待刷隊列 ---
func prepare_next_wave():
	if level_wave_array.is_empty(): return
		
	var wave_data = level_wave_array[0]
	
	# 展開 amount 數量的怪物到隊列
	match wave_data["mode"]:
		1:
			for i in range(wave_data["amount"]):
				current_wave_queue.append(wave_data["unit"])
		2:
			var temp_pool = wave_data["pool"].duplicate()
			temp_pool.shuffle()
			var amt = min(wave_data["amount"], temp_pool.size())
			for i in range(amt):
				current_wave_queue.append(temp_pool.pop_front())
	
	# 處理 repeat
	if wave_data.has("repeat"):
		wave_data["repeat"] -= 1
		if wave_data["repeat"] <= 0:
			level_wave_array.pop_front()
	else:
		level_wave_array.pop_front()

func setup_test_level():
	# 這裡模擬填入數據
	level_wave_array = [
		# --- 階段 1：基礎防線測試 (Count 0 - 80) ---
		# 介紹 red 的坦度與 blue 的衝擊
		{"mode": 1, "unit": "blue", "amount": 1, "repeat": 10},          # 10 count
		{"mode": 1, "unit": "blue", "amount": 2, "repeat": 10},         # 20 count
		{"mode": 2, "pool": ["red", "blue"], "amount": 2, "repeat": 10},# 20 count
		{"mode": 1, "unit": "Soulblade", "amount": 1, "repeat": 10},    # 10 count (初識精英)
		{"mode": 2, "pool": ["blue", "red"], "amount": 4, "repeat": 5}, # 20 count

		# --- 階段 2：火力與射程威脅 (Count 80 - 180) ---
		# 加入 snow ball shooter 考驗玩家對後排的處理
		{"mode": 1, "unit": "snow ball shooter", "amount": 1, "repeat": 10}, # 10 count
		{"mode": 1, "unit": "boxer", "amount": 1, "repeat": 10},             # 10 count
		{"mode": 2, "pool": ["red", "snow ball shooter"], "amount": 3, "repeat": 10}, # 30 count
		{"mode": 2, "pool": ["blue", "boxer"], "amount": 3, "repeat": 10},            # 30 count
		{"mode": 1, "unit": "Butterfly kun", "amount": 2, "repeat": 10},              # 20 count

		# --- 階段 3：中型混合軍團 (Count 180 - 300) ---
		# 強調 Soulblade 與 Boxer 的前排壓力
		{"mode": 1, "unit": "Soulblade", "amount": 2, "repeat": 15},    # 30 count
		{"mode": 1, "unit": "red", "amount": 5, "repeat": 6},           # 30 count (大批肉盾)
		{"mode": 2, "pool": ["boxer", "Butterfly kun"], "amount": 3, "repeat": 10}, # 30 count
		{"mode": 2, "pool": ["blue", "snow ball shooter"], "amount": 3, "repeat": 10}, # 30 count

		# --- 階段 4：高壓混亂期 (Count 300 - 450) ---
		# 開始出現高頻率、高強度的隨機組合
		{"mode": 2, "pool": ["Soulblade", "boxer", "red"], "amount": 4, "repeat": 10}, # 40 count
		{"mode": 1, "unit": "Butterfly kun", "amount": 3, "repeat": 10},               # 30 count
		{"mode": 1, "unit": "snow ball shooter", "amount": 4, "repeat": 5},            # 20 count
		{"mode": 2, "pool": ["red", "blue", "boxer", "Soulblade", "Butterfly kun"], "amount": 6, "repeat": 10}, # 60 count

		# --- 階段 5：終極高潮 (Count 450 - 500+) ---
		# 最終的大規模進攻與 super_boss 亂入
		{"mode": 1, "unit": "super_boss", "amount": 1, "repeat": 5},     # 5 count (極速衝擊)
		{"mode": 1, "unit": "red", "amount": 10, "repeat": 2},           # 20 count (最後的肉牆)
		{"mode": 2, "pool": ["boxer", "Soulblade", "bf_k"], "amount": 5, "repeat": 5}, # 25 count
		{"mode": 1, "unit": "super_boss", "amount": 1, "repeat": 5}      # 最後 5 隻收尾
	]

func spawn_enemy_1(s_id: String):
	var new_enemy = Global.minion_scene.instantiate()
	new_enemy.ini_w_data(UnitAutoload.unit_dic[s_id])
	
	new_enemy.z_index = 3
	new_enemy.position = Vector2(1769, 735)
	new_enemy.side = "enemy"
	new_enemy.add_to_group("unit")
	new_enemy.add_to_group("enemy")
	
	GM.add_child(new_enemy)
	SignalBus.unit_spawned.emit(new_enemy)
	new_enemy.refresh()


#endregion

#region 5. UI 更新 (UI Updates)
func update_wave_number_label():
	if wave_number_label:
		# 這裡維持原本的顯示邏輯，或者你可以改為顯示 level_wave_array 的剩餘進度
		wave_number_label.text = "wave : " + str(count / 10 + 1)
#endregion

#region 外部接口 (Public API)

## 開啟或關閉刷怪功能
func function_switch(v: bool):
	functioning = v
	# 移除原本在這裡的 prepare_next_wave()
	# 這樣開啟後，會等足 7 秒才出第一波

## 重置當前關卡狀態與數據
func reset_level():
	count = 0
	current_wave_queue.clear()
	setup_test_level() # 重新初始化 level_wave_array

## [新增] 立即插隊：將一個 wave_data 插入到生成隊列的最前端
## wave_data 格式範例: {"mode": 1, "unit": "red", "amount": 3}
func inject_wave_immediate(wave_data: Dictionary):
	# 直接將這筆 wave 數據插入到 level_wave_array 的 index 0 (最前面)
	# 這樣 prepare_next_wave 下次執行時就會先抓到這一筆
	level_wave_array.push_front(wave_data)
	
	print("已將插隊數據放入關卡序列首位，將在下一個 7 秒循環觸發")

## [新增] 外部手動添加波次：在現有關卡序列最後方追加新的波次
func add_wave_to_end(wave_data: Dictionary):
	level_wave_array.append(wave_data)

#endregion
