class_name ShopPool
extends Resource

@export var items: Array[ItemData] = []
@export var magics: Array[MagicData] = []
@export var minions: Array[minion_data] = []


## 從池中隨機抽取 count 件商品並移除，回傳抽到的陣列。
## 若池中商品數不足，回傳全部剩餘商品。
func draw_random(count: int) -> Array:
	
	var pool: Array = []
	pool.append_array(items)
	pool.append_array(magics)
	pool.append_array(minions)
	pool.shuffle()

	var actual_count := mini(count, pool.size())
	var drawn: Array = []
	for i in actual_count:
		var entry = pool[i]
		drawn.append(entry)
		if entry is ItemData:
			items.erase(entry)
		elif entry is MagicData:
			magics.erase(entry)
		else:
			minions.erase(entry)

	print("[ShopPool] 抽出 %d 件：" % drawn.size())
	for d in drawn:
		print("  + ", _entry_name(d))
	print("[ShopPool] 剩餘 — items:%d  magics:%d  minions:%d" % [items.size(), magics.size(), minions.size()])

	return drawn


static func _entry_name(entry: Resource) -> String:
	if entry is minion_data: return "minion  | %s (cost:%d)" % [entry.minion_name, entry.cost]
	if entry is ItemData:    return "item    | %s (price:%d)" % [entry.id, entry.price]
	if entry is MagicData:   return "magic   | %s (price:%d)" % [entry.id, entry.price]
	return str(entry)
