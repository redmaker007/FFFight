extends sub_hex_data
class_name change_bank_money_rate_hex

#region 1. 導出參數 (Export Properties)
@export_group("收入修正 (Income)")
## 收入乘數增量 (例如 0.1 代表收入 +10%)
@export var income_mul: float = 0.0
## 收入固定加值 (例如 1 代表每秒多 $1)
@export var income_add: float = 0.0

@export_group("升級費修正 (Upgrade Cost)")
## 升級費乘數增量 (例如 -0.1 代表費用打 9 折)
@export var upgrade_mul_delta: float = 0.0
## 升級費固定加值 (例如 -10 代表便宜 $10)
@export var upgrade_add_delta: float = 0.0
#endregion

#region 2. 核心邏輯 (Core Logic)

func hex_process(gm):
	# 修改收入：使用 1.0 + 增量來疊加倍率
	if income_mul != 0 or income_add != 0:
		gm.ms.add_income_modifier(1.0 + income_mul, income_add)
	
	# 修改升級費用：使用 1.0 + 增量來疊加倍率
	if upgrade_mul_delta != 0 or upgrade_add_delta != 0:
		gm.ms.add_upgrade_modifier(1.0 + upgrade_mul_delta, upgrade_add_delta)


func hex_process_take_back(gm):
	# 呼叫 Money_system 的重置接口，回歸原始數據
	if gm.ms.has_method("reset_modifiers"):
		gm.ms.reset_modifiers()
	else:
		# 後備方案：手動歸位
		gm.ms.income_multiplyer = 1.0
		gm.ms.income_additioner = 0.0
		gm.ms.upgrade_multiplayer = 1.0
		gm.ms.upgrade_additioner = 0.0
		gm.ms.update_text()

#endregion

#region 3. 描述文本 (Description)

func get_description() -> String:
	var descriptions = []
	
	# 收入描述
	if income_mul != 0:
		descriptions.append("Bank income " + ("+" if income_mul > 0 else "") + str(income_mul * 100) + "%")
	if income_add != 0:
		descriptions.append("Bank income " + ("+" if income_add > 0 else "") + str(income_add) + "/s")
	
	# 升級費描述
	if upgrade_mul_delta != 0:
		descriptions.append("Bank upgrade cost " + ("-" if upgrade_mul_delta < 0 else "+") + str(abs(upgrade_mul_delta) * 100) + "%")
	if upgrade_add_delta != 0:
		descriptions.append("Bank upgrade cost " + ("-" if upgrade_add_delta < 0 else "+") + "$" + str(abs(upgrade_add_delta)))
	
	var base_desc = ", ".join(descriptions)
	
	if one_time:
		return base_desc + " (Next round only)."
	else:
		return base_desc + " (Permanent)."

#endregion
