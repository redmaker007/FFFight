extends sub_hex_data
class_name add_wave_hex

# ===== 出兵模式 =====
@export_category("出兵模式")
@export_enum("instant_once", "every_X_count", "every_X_wave") var trigger_mode: int = 0

# ===== 出兵内容 =====
@export_category("模式選擇")
## 1:单一 2:随机池不放回 4:随机池放回 5:bonus信号
@export_range(1, 5) var mode: int = 1

@export_category("模式 1 配置 (單一)")
@export var unit_id: String

@export_category("模式 2 / 4 配置 (隨機池)")
@export var unit_id_pool: Array[String]

@export_category("通用配置")
@export var amount: int
## 可選：重複觸發次數，不填則觸發一次
@export var repeat: int = 1

# ===== 触发配置 =====
@export_category("触发配置（trigger_mode != instant_once 时生效）")
@export var every_X: int = 5

# ===== 内部状态 =====
var _gm = null

# ===== 工具函数 =====
func get_wave_data() -> Dictionary:
	var wave_data: Dictionary = {"mode": mode, "amount": amount}
	if mode == 1:
		wave_data["unit"] = unit_id
	elif mode == 2 or mode == 4:
		wave_data["pool"] = unit_id_pool.duplicate()
	if repeat > 1:
		wave_data["repeat"] = repeat
	return wave_data

func _inject():
	if _gm == null or _gm.es == null:
		push_error("add_wave_hex: 找不到 EnemySpawner")
		return
	if _gm.es.has_method("inject_burst_wave"):
		_gm.es.inject_burst_wave(get_wave_data())

# ===== 核心接口 =====
func hex_process(gm):
	_gm = gm
	if trigger_mode == 0:
		_inject()

func on_enemy_count_changed(count: int):
	if trigger_mode != 1 or every_X <= 0 or count <= 0:
		return
	if count % every_X == 0:
		_inject()

func on_wave_count_changed(wave_count: int):
	
	if trigger_mode != 2 or every_X <= 0 or wave_count <= 0:
		return
	if wave_count % every_X == 0:
		_inject()

# ===== 描述 =====
func _get_base_description() -> String:
	var trigger_desc = _get_trigger_desc()
	match mode:
		1:
			return tr("ADD_WAVE_SPAWN") + " " + str(amount) + " " + tr("ADD_WAVE_UNIT") + ": " + tr(("Unit_"+unit_id+"_NAME").to_upper()) + " " + trigger_desc
		2:
			return tr("ADD_WAVE_SPAWN") + " " + str(amount) + " " + tr("ADD_WAVE_FROM_POOL_NO_REPEAT") + ": " + ", ".join(unit_id_pool) + " " + trigger_desc
		4:
			return tr("ADD_WAVE_SPAWN") + " " + str(amount) + " " + tr("ADD_WAVE_FROM_POOL_REPEAT") + ": " + ", ".join(unit_id_pool) + " " + trigger_desc
		5:
			return tr("ADD_WAVE_BONUS_SIGNAL") + " " + trigger_desc
	return ""

func _get_trigger_desc() -> String:
	match trigger_mode:
		0: return "(" + tr("TRIGGER_INSTANT") + ")"
		1: return "(" + tr("TRIGGER_EVERY_X_COUNT").replace("{X}", str(every_X)) + ")"
		2: return "(" + tr("TRIGGER_EVERY_X_WAVE").replace("{X}", str(every_X)) + ")"
	return ""
