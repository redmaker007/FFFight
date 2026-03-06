extends sub_hex_data
class_name add_wave_hex

# --- 編輯器配置 (Export Variables) ---
@export_category("模式選擇")
## 模式 1: 單一怪物輸出 | 模式 2: 從隨機池抽取
@export_range(1, 2) var mode: int = 1 

@export_category("模式 1 配置 (單一)")
## 模式 1 使用的敵人 ID
@export var unit_id: String

@export_category("模式 2 配置 (隨機池)")
## 模式 2 使用的敵人 ID 陣列 (抽完不放回)
@export var unit_id_pool: Array[String]

@export_category("通用配置")
## 該波次生成的敵人總數量
@export var amount: int

# --- 核心邏輯 (Process) ---
func hex_process(gm):
	# 用於構建傳遞給 Spawner 的字典數據
	var wave_data: Dictionary = {
		"mode": mode,
		"amount": amount
	}

	# 根據模式決定傳入的 Key 與對應變量
	if mode == 1:
		wave_data["unit"] = unit_id
	else:
		# 注意：模式 2 這裡必須對應你 export 的 pool 陣列
		wave_data["pool"] = unit_id_pool # #修正：原本代碼中誤用了 unit_id
		
	# 呼叫 EnemySpawner (gm.es) 的插隊接口
	if gm.es and gm.es.has_method("inject_wave_immediate"):
		gm.es.inject_wave_immediate(wave_data)
	else:
		push_error("add_wave_hex: 找不到 EnemySpawner 或 inject_wave_immediate 函數")
