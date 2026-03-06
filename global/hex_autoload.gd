extends Node

#region 1. 變量與配置
## 格式：{ "C": { "hex_name": hex_data }, "B": { ... } }
var hex_dic = {} 

## 設定 Hex 資源的根目錄 (確保路徑正確)
@export_dir var hex_root_path: String = "res://resources/hex/"

# 稀有度權重配置
var rarity_weights = {
	"S": 5,    # 5%
	"A": 15,   # 15%
	"B": 30,   # 30%
	"C": 50    # 50%
}
#endregion

#region 2. 自動載入邏輯 (File Scanner)
func _ready() -> void:
	# 遊戲啟動時自動執行掃描
	load_all_hex_resources(hex_root_path)

## 遍歷根目錄下的所有稀有度分級資料夾 (A, B, C, D, S)
func load_all_hex_resources(root_path: String):
	var dir = DirAccess.open(root_path)
	if not dir:
		push_error("無法開啟 Hex 根目錄: " + root_path)
		return

	dir.list_dir_begin()
	var sub_dir_name = dir.get_next()

	while sub_dir_name != "":
		# 只處理資料夾，並排除隱藏文件
		if dir.current_is_dir() and not sub_dir_name.begins_with("."):
			var rarity_key = sub_dir_name
			if not hex_dic.has(rarity_key):
				hex_dic[rarity_key] = {}
			
			_scan_rarity_folder(root_path + sub_dir_name + "/", rarity_key)
			
		sub_dir_name = dir.get_next()
	dir.list_dir_end()
	print("HexAutoload: 載入完成，目前分類: ", hex_dic.keys())

## 掃描特定稀有度資料夾內的文件並註冊
func _scan_rarity_folder(path: String, rarity: String):
	var dir = DirAccess.open(path)
	if not dir: return

	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		if not dir.current_is_dir():
			# 支持 .tres 以及匯出後的 .remap 格式
			if file_name.ends_with(".tres") or file_name.ends_with(".tres.remap"):
				var full_path = path + file_name.replace(".remap", "")
				var res = load(full_path)
				
				if res is hex_data:
					# 這裡使用 hex_name 作為內層 Key
					hex_dic[rarity][res.hex_name] = res
					
		file_name = dir.get_next()
	dir.list_dir_end()
#endregion

#region 3. 核心抽取算法 (Weighted RNG)
## 根據概率從字典中抽取 N 個不重複的 Hex
func draw_hex_multiple(count: int) -> Array:
	var results = []
	# 使用 deep copy 複製臨時字典，確保 erase 不會影響全局數據
	var temp_dic = hex_dic.duplicate(true) 

	for i in range(count):
		var picked_rarity = _get_weighted_rarity()
		
		# 檢查該稀有度是否有貨，沒貨則降級備選
		if not temp_dic.has(picked_rarity) or temp_dic[picked_rarity].is_empty():
			picked_rarity = _get_backup_rarity(temp_dic)
		
		if picked_rarity == "": 
			break 

		var rarity_pool = temp_dic[picked_rarity]
		var keys = rarity_pool.keys()
		var random_key = keys.pick_random()
		var hex_instance = rarity_pool[random_key]
		
		results.append(hex_instance)
		
		# 從臨時池移除，保證單次抽出的 3 個不重複
		temp_dic[picked_rarity].erase(random_key)
		
	return results

func _get_weighted_rarity() -> String:
	var total_weight = 0
	for r in rarity_weights:
		total_weight += rarity_weights[r]
	
	var roll = randi() % total_weight
	var current_sum = 0
	
	for r in rarity_weights:
		current_sum += rarity_weights[r]
		if roll < current_sum:
			return r
	return "C"

func _get_backup_rarity(temp_dic: Dictionary) -> String:
	# 當指定等級沒貨，從常見到稀有尋找任何可用的 Hex
	for r in ["C", "B", "A", "S"]:
		if temp_dic.has(r) and not temp_dic[r].is_empty():
			return r
	return ""
#endregion
