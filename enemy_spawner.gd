extends Node

#region 1. 變量與配置 (Properties & Variables)
@export var spec_unit: String
@export var constant_spawn_cd: float = 5.0
@export var burst_interval: float = 0.1
@export_group("Progress Bar")
@export var progress_bar_position: Vector2 = Vector2(900, 50)
@export var progress_bar_size: int = 64
@export var progress_bar_scale: float = 1.0
@export var progress_bar_wave_scale: float = 1.12
@export var progress_bar_tint_under: Color = Color(0.12, 0.15, 0.22, 0.75)
@export var progress_bar_tint_progress: Color = Color(0.95, 0.78, 0.15)

@onready var GM = get_parent()
@onready var wave_number_label = GM.wave_number_label
@onready var spawner_cd_progress: TextureProgressBar = %SpawnerCDProgress


var pool = ["red", "blue", "boxer", "snow_b_s", "bf_k"]
var functioning: bool = false

var spawn_CD: float = 0
var burst_spawn_CD: float = 0
var is_bursting: bool = false
var count: int = 0
var theme: int = 0
var wave_count: int = 1

# 進度條 tween 引用（用於在 wave_end 時取消殘留動畫）
var _bar_tween: Tween = null

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
	SignalBus.wave_count_changed.emit(wave_count)
	update_wave_number_label()
	_setup_progress_bar()

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
					_on_wave_start()
		else:
			spawn_CD += delta
			spawner_cd_progress.value = (1.0 - spawn_CD / constant_spawn_cd) * 100.0

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
				_on_wave_end()
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
	SignalBus.wave_count_changed.emit(wave_count)
	update_wave_number_label()
	spawner_cd_progress.value = 100.0
	spawner_cd_progress.show()
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
			print(wave_count)
			SignalBus.bg_theme_change.emit(wave_count % 4)
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
	new_enemy.position = Vector2(1775, 735)
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


func _on_wave_start() -> void:
	# 閃爍提示後隱藏（敵人生成中不需要顯示倒計時）
	if _bar_tween and _bar_tween.is_running():
		_bar_tween.kill()
	var ws := progress_bar_wave_scale
	var s  := progress_bar_scale
	_bar_tween = spawner_cd_progress.create_tween().set_parallel(true)
	# Phase 1 (t=0 ~ 0.10s)：放大 + 變黃，同步進行
	_bar_tween.tween_property(spawner_cd_progress, "scale",    Vector2(ws, ws),      0.10)
	_bar_tween.tween_property(spawner_cd_progress, "modulate", Color(1.5, 1.2, 0.2), 0.10)
	# Phase 2 (t=0.10 ~ 0.24s)：縮回 + 還原白色，同步進行
	_bar_tween.tween_property(spawner_cd_progress, "scale",    Vector2(s, s), 0.14).set_trans(Tween.TRANS_ELASTIC).set_delay(0.10)
	_bar_tween.tween_property(spawner_cd_progress, "modulate", Color(1, 1, 1), 0.14).set_delay(0.10)
	# 動畫結束後隱藏
	_bar_tween.tween_callback(spawner_cd_progress.hide).set_delay(0.24)


func _on_wave_end() -> void:
	# 先殺掉 wave_start 的殘留 tween，避免它的 .hide() callback 延遲觸發
	if _bar_tween and _bar_tween.is_running():
		_bar_tween.kill()
	spawner_cd_progress.modulate = Color(1, 1, 1)
	spawner_cd_progress.scale    = Vector2(progress_bar_scale, progress_bar_scale)
	spawner_cd_progress.value    = 100.0
	spawner_cd_progress.show()


func _setup_progress_bar() -> void:
	var tex := _make_ring_texture(progress_bar_size)
	spawner_cd_progress.texture_under    = tex
	spawner_cd_progress.texture_progress = tex
	spawner_cd_progress.tint_under        = progress_bar_tint_under
	spawner_cd_progress.tint_progress     = progress_bar_tint_progress
	spawner_cd_progress.fill_mode         = TextureProgressBar.FILL_CLOCKWISE
	spawner_cd_progress.value             = 100.0
	var s := progress_bar_scale
	spawner_cd_progress.scale             = Vector2(s, s)
	spawner_cd_progress.pivot_offset      = Vector2(progress_bar_size * 0.5, progress_bar_size * 0.5)
	spawner_cd_progress.position          = progress_bar_position


## 生成一張 size×size 的白色環形 ImageTexture（無需外部貼圖）
func _make_ring_texture(size: int) -> ImageTexture:
	var img := Image.create(size, size, false, Image.FORMAT_RGBA8)
	var center := Vector2(size * 0.5, size * 0.5)
	var r_outer := size * 0.5 - 1.0
	var r_inner := r_outer * 0.62          # 環寬約 38% 半徑
	for x in size:
		for y in size:
			var d := Vector2(x, y).distance_to(center)
			if d <= r_outer and d >= r_inner:
				img.set_pixel(x, y, Color.WHITE)
	return ImageTexture.create_from_image(img)
#endregion

#region 外部接口 (Public API)
func function_switch(v: bool):
	functioning = v
	if v:
		spawner_cd_progress.value = 100.0
		spawner_cd_progress.show()
	else:
		spawner_cd_progress.hide()


func reset_wave_timer() -> void:
	spawn_CD       = 0.0
	burst_spawn_CD = 0.0
	is_bursting    = false
	spawner_cd_progress.value = 100.0

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
