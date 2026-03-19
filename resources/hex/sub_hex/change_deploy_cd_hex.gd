extends sub_hex_data
class_name change_deploy_cd_hex

# --- 編輯器配置 (Export Variables) ---

@export_group("修正數值")
## 乘法修正值 (例如 0.8 代表 CD 變 80%)
@export var mul_value: float = 1.0
## 加法修正值 (例如 -0.5 代表 CD 減少 0.5 秒)
@export var add_value: float = 0.0

@export_group("生效模式")
## 模式選擇：0 = 全體單位 | 1 = 單一特定單位
@export_enum("All Units:0", "Single Unit:1") var target_mode: int = 0
## 如果選擇單一單位模式，請輸入目標單位的 unit_id (例如 "blue")
@export var target_unit_id: String = ""

# --- 核心邏輯 (Methods) ---

## 當獲得此 Hex 時觸發：使用「依據模式 (ADD)」進行修改
func hex_process(gm):
	if target_mode == 0:
		# 修改全體按鈕 (模式 1 為 ADD)
		gm.modify_all_buttons_cd(mul_value, add_value, 1)
	else:
		# 修改特定按鈕 (模式 1 為 ADD)
		if target_unit_id != "":
			gm.modify_unit_button_cd(target_unit_id, mul_value, add_value, 1)
		else:
			push_warning("change_deploy_cd_hex: 模式為單一單位但未填寫 target_unit_id")

## 當失去此 Hex 或重置時觸發：使用「覆蓋模式 (OVERRIDE)」將 CD 改回初始狀態
func hex_process_take_back(gm):
	# 使用覆蓋模式 (模式 0 為 OVERRIDE)，將倍率設為 1，偏移量設為 0
	if target_mode == 0:
		gm.modify_all_buttons_cd(1.0, 0.0, 0)
		
	else:
		if target_unit_id != "":
			gm.modify_unit_button_cd(target_unit_id, 1.0, 0.0, 0)

func _get_base_description() -> String:
	var parts: Array[String] = []

	if mul_value != 1.0:
		var sign = "+" if mul_value > 1.0 else ""
		parts.append(tr("DEPLOY_CD") + " " + sign + str((mul_value - 1.0) * 100) + "%")
	if add_value != 0.0:
		var sign = "+" if add_value > 0 else ""
		parts.append(tr("DEPLOY_CD") + " " + sign + str(add_value) + "s")

	if parts.size() == 0:
		return ""

	var base_desc = ", ".join(parts)

	if target_mode == 0:
		return base_desc + " (" + tr("TARGET_ALL") + ")"
	else:
		return base_desc + " (" + tr("TARGET_SINGLE") + ": " + target_unit_id + ")"
