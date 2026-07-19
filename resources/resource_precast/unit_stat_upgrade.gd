class_name UnitStatUpgrade
extends Resource

## 對應 minion.gd 的 add_mod(stat, value, aom) 接口
## aom: true = 加法 mod，false = 乘法 mod

@export var display_name: String = ""

## 要修改的屬性名稱，對應 minion.gd stat_dic 的 key
## 可選：max_hp / att / att_r / att_spd / speed
@export_enum("max_hp", "att", "att_r", "att_spd", "speed") var stat_name: String = "max_hp"

## 修改量
@export var value: float = 0.0

## true = 加法 mod，false = 乘法 mod（百分比，如 0.2 = +20%）
@export var additive: bool = true
