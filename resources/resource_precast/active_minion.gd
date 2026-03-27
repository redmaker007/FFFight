class_name ActiveMinion
extends Resource

signal leveled_up(new_level: int)

# 指向靜態數據庫（minion_data.tres）
@export var data: minion_data

# 當局狀態
@export var current_level: int = 1
@export var experience: int = 0

# TODO: 進化路線系統 (Evolution Path)
# 預計結構：@export var evolution_path: Array[MinionData]
# 當 experience 達到閾值時，提示玩家選擇分支進化

# TODO: 當局增益效果清單 (Buff List)
# 預計結構：@export var active_buffs: Array[stat_mod]
# 由 Hex 效果的 give_target_stat、grant_ability_hex 等寫入


## 增加經驗值，滿 10 點自動升級（上限 Lv.3）
func add_experience(amount: int) -> void:
	if current_level >= 3:
		return
	experience += amount
	if experience >= 10:
		experience -= 10
		current_level += 1
		leveled_up.emit(current_level)


## 取得屬性數值。
## 初步邏輯直接返回 data 中的基礎值；
## 未來可在此加入等級加成與 Buff 疊算。
func get_stat(stat_name: String) -> float:
	if data == null:
		push_error("ActiveMinion.get_stat: data 為 null")
		return 0.0
	match stat_name:
		"speed":    return data.speed
		"max_hp":   return data.max_hp
		"att":      return data.att
		"att_r":    return data.att_r
		"att_spd":  return data.att_spd
		_:
			push_warning("ActiveMinion.get_stat: 未知屬性 '%s'" % stat_name)
			return 0.0
