extends Node

#region 1. 變量與配置 (Properties & Variables)
@export var spec_unit: String
@export var constant_spawn_cd: float = 5.0
@export var burst_interval: float = 0.1

@onready var GM = get_parent()
@onready var wave_number_label = GM.wave_number_label

var pool = ["red", "blue", "boxer", "snow_b_s", "bf_k"]
var functioning: bool = false

var spawn_CD: float = 0
var burst_spawn_CD: float = 0
var is_bursting: bool = false
var count: int = 0
var theme: int = 0
var wave_count: int = 1

# 立即插播隊列（不污染主流程）
var burst_override_queue: Array = []
var is_override_bursting: bool = false
var override_burst_cd: float = 0.0

# 模式說明：
# mode 1: {"mode": 1, "unit": "red", "amount": 5}
#   將指定 unit 刷出 amount 隻，依序加入隊列
#
# mode 2: {"mode": 2, "pool": ["red", "blue"], "amount": 3}
#   將 pool 洗牌後取前 amount 隻；若 amount > pool.size()，截斷至 pool.size()
#
# mode 3: {"mode": 3, "amount": 4.0}
#   修改 constant_spawn_cd 為 amount 秒，不刷怪，立即生效並繼續取下一條
#
# mode 4: {"mode": 4, "pool": ["red", "blue"], "amount": 12}
#   從 pool 中有放回地隨機抽取 amount 隻（可重複）
#
# mode 5: {"mode": 5}
#   發出 bonus_hex 信號，不刷怪，立即生效並繼續取下一條
#
# 可選參數 repeat: {"mode": 1, "unit": "red", "amount": 5, "repeat": 3}
#   每次觸發消耗一次 repeat；歸零後才從 level_wave_array 移除
#   不填則觸發一次後立即移除

var level_wave_array: Array = []
var current_wave_queue: Array = []
#endregion

#region 2. 生命周期 (Lifecycle)
func _ready() -> void:
	await get_tree().process_frame

	GM = get_parent()
	wave_number_label = GM.wave_number_label

	setup_test_level()
	SignalBus.on_language_change.connect(update_wave_number_label)
	count = 0
	wave_count = 1
	update_wave_number_label()

func _process(delta: float) -> void:
	if not functioning:
		return

	# --- A. 立即插播 burst（優先處理，阻塞主流程） ---
	if is_override_bursting:
		if override_burst_cd >= burst_interval:
			if not burst_override_queue.is_empty():
				var next_unit = burst_override_queue.pop_front()
				spawn_enemy_1(next_unit)
				count += 1
				SignalBus.enemy_count_changed.emit(count)

				if count % 10 == 0:
					theme += 1
					SignalBus.bg_theme_change.emit(theme % 4)

				override_burst_cd = 0
			else:
				is_override_bursting = false
		else:
			override_burst_cd += delta

		return

	# --- B. 主波次觸發邏輯 ---
	if not is_bursting:
		if spawn_CD >= constant_spawn_cd:
			if current_wave_queue.is_empty() and not level_wave_array.is_empty():
				prepare_next_wave()

				if not current_wave_queue.is_empty():
					is_bursting = true
					burst_spawn_CD = burst_interval
					spawn_CD = 0
		else:
			spawn_CD += delta

	# --- C. 主連刷處理邏輯 ---
	if is_bursting:
		if burst_spawn_CD >= burst_interval:
			if not current_wave_queue.is_empty():
				var next_unit = current_wave_queue.pop_front()
				spawn_enemy_1(next_unit)
				count += 1
				SignalBus.enemy_count_changed.emit(count)

				if count % 10 == 0:
					theme += 1
					SignalBus.bg_theme_change.emit(theme % 4)

				burst_spawn_CD = 0
			else:
				is_bursting = false
		else:
			burst_spawn_CD += delta
#endregion

#region 3. 核心控制 (Core Controls)
func reset_whole():
	count = 0
	wave_count = 1
	spawn_CD = 0
	burst_spawn_CD = 0
	is_bursting = false
	current_wave_queue.clear()

	burst_override_queue.clear()
	override_burst_cd = 0
	is_override_bursting = false

	update_wave_number_label()
#endregion

#region 4. 刷怪邏輯 (Spawn Logic)
func prepare_next_wave():
	while current_wave_queue.is_empty() and not level_wave_array.is_empty():
		var wave_data = level_wave_array[0]
		var mode = wave_data["mode"]

		match mode:
			1:
				for i in range(wave_data["amount"]):
					current_wave_queue.append(wave_data["unit"])

			2:
				var temp_pool = wave_data["pool"].duplicate()
				temp_pool.shuffle()
				var amt = min(wave_data["amount"], temp_pool.size())
				for i in range(amt):
					current_wave_queue.append(temp_pool.pop_front())

			3:
				constant_spawn_cd = float(wave_data["amount"])
				print("mode 3 生效，constant_spawn_cd 已修改為: ", constant_spawn_cd)

			4:
				var temp_pool = wave_data["pool"]
				if temp_pool.is_empty():
					push_warning("mode 4 的 pool 是空的")
				else:
					for i in range(wave_data["amount"]):
						var rand_unit = temp_pool[randi() % temp_pool.size()]
						current_wave_queue.append(rand_unit)

			5:
				SignalBus.emit_signal("bonus_hex")
				print("mode 5 生效，已發出 bonus_hex 信號")

		var finished_this_wave_data := false

		if wave_data.has("repeat"):
			wave_data["repeat"] -= 1
			if wave_data["repeat"] <= 0:
				finished_this_wave_data = true
				level_wave_array.pop_front()
		else:
			finished_this_wave_data = true
			level_wave_array.pop_front()

		if finished_this_wave_data and mode in [1, 2, 4]:
			wave_count += 1
			SignalBus.wave_count_changed.emit(wave_count)
			update_wave_number_label()

# 將 wave_data 展開成單個單位隊列，供 inject_burst_wave 使用
func build_wave_queue(wave_data: Dictionary) -> Array:
	var result: Array = []
	var mode = wave_data.get("mode", 1)

	match mode:
		1:
			for i in range(wave_data.get("amount", 0)):
				result.append(wave_data["unit"])

		2:
			var temp_pool = wave_data["pool"].duplicate()
			temp_pool.shuffle()
			var amt = min(wave_data.get("amount", 0), temp_pool.size())
			for i in range(amt):
				result.append(temp_pool.pop_front())

		4:
			var temp_pool = wave_data["pool"]
			if not temp_pool.is_empty():
				for i in range(wave_data.get("amount", 0)):
					result.append(temp_pool[randi() % temp_pool.size()])

	return result

func setup_test_level():
	level_wave_array = [
		{"mode": 3, "amount": 6},
		{"mode": 1, "unit": "blue", "amount": 1, "repeat": 3},
		{"mode": 1, "unit": "blue", "amount": 2, "repeat": 3},
		{"mode": 2, "pool": ["red", "blue"], "amount": 2, "repeat": 3},
		{"mode": 1, "unit": "soul_b", "amount": 2, "repeat": 4},
		{"mode": 4, "pool": ["blue", "red"], "amount": 4, "repeat": 3},

		{"mode": 3, "amount": 5},
		{"mode": 1, "unit": "snow_b_s", "amount": 3, "repeat": 3},
		{"mode": 1, "unit": "boxer", "amount": 4, "repeat": 3},
		{"mode": 4, "pool": ["red", "snow_b_s"], "amount": 6, "repeat": 3},
		{"mode": 4, "pool": ["blue", "boxer"], "amount": 6, "repeat": 3},
		{"mode": 1, "unit": "bf_k", "amount": 2, "repeat": 3},
		{"mode": 1, "unit": "s_s", "amount": 1, "repeat": 1},

		{"mode": 3, "amount": 4},
		{"mode": 1, "unit": "soul_b", "amount": 3, "repeat": 4},
		{"mode": 1, "unit": "red", "amount": 5, "repeat": 3},
		{"mode": 4, "pool": ["boxer", "bf_k"], "amount": 6, "repeat": 3},
		{"mode": 4, "pool": ["blue", "snow_b_s"], "amount": 6, "repeat": 3},
		{"mode": 4, "pool": ["red", "soul_b", "boxer"], "amount": 7, "repeat": 3},
		{"mode": 1, "unit": "snow_b_s", "amount": 5, "repeat": 2},
		{"mode": 1, "unit": "s_s", "amount": 1, "repeat": 1},

		{"mode": 3, "amount": 3},
		{"mode": 4, "pool": ["soul_b", "boxer", "red"], "amount": 7, "repeat": 3},
		{"mode": 1, "unit": "bf_k", "amount": 4, "repeat": 3},
		{"mode": 1, "unit": "snow_b_s", "amount": 4, "repeat": 3},
		{"mode": 4, "pool": ["red", "blue", "boxer", "soul_b"], "amount": 8, "repeat": 3},
		{"mode": 4, "pool": ["blue", "snow_b_s", "bf_k"], "amount": 7, "repeat": 3},
		{"mode": 1, "unit": "s_s", "amount": 1, "repeat": 2},
		{"mode": 4, "pool": ["red", "blue", "boxer", "soul_b", "bf_k"], "amount": 9, "repeat": 3},
		{"mode": 4, "pool": ["snow_b_s", "bf_k", "boxer"], "amount": 8, "repeat": 2},

		{"mode": 3, "amount": 1.7},
		{"mode": 1, "unit": "s_s", "amount": 1, "repeat": 2},
		{"mode": 1, "unit": "red", "amount": 7, "repeat": 3},
		{"mode": 4, "pool": ["boxer", "soul_b", "bf_k"], "amount": 8, "repeat": 3},
		{"mode": 4, "pool": ["red", "blue", "boxer", "snow_b_s"], "amount": 10, "repeat": 3},
		{"mode": 1, "unit": "bf_k", "amount": 5, "repeat": 3},
		{"mode": 1, "unit": "s_s", "amount": 1, "repeat": 2},
		{"mode": 4, "pool": ["red", "blue", "boxer", "soul_b", "bf_k"], "amount": 10, "repeat": 3},
		{"mode": 4, "pool": ["red", "s_s", "snow_b_s"], "amount": 6, "repeat": 2},
		{"mode": 1, "unit": "s_s", "amount": 1, "repeat": 4}
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
		wave_number_label.text = tr("WAVE") + " : " + str(wave_count)
#endregion

#region 外部接口 (Public API)
func function_switch(v: bool):
	functioning = v

func reset_level():
	reset_whole()
	setup_test_level()

## 插入到 level_wave_array 最前端，下一個 CD 循環觸發
func inject_wave_immediate(wave_data: Dictionary):
	level_wave_array.push_front(wave_data)

## 立即插播，不等 CD，不污染主流程；若已有插播則覆蓋
func inject_burst_wave(wave_data: Dictionary):
	var queue = build_wave_queue(wave_data)
	if queue.is_empty():
		return

	burst_override_queue = queue
	is_override_bursting = true
	override_burst_cd = burst_interval

func add_wave_to_end(wave_data: Dictionary):
	level_wave_array.append(wave_data)
#endregion
