extends Node

# ── 信號 ────────────────────────────────────────────────
signal item_added(item: ItemData)
signal magic_added(magic: MagicData)
signal minion_added(minion: ActiveMinion)

# ── 儲存陣列 ─────────────────────────────────────────────
# 神器 / 法術（ItemData.stackable 區分是否可疊加）
var items: Array[ItemData] = []

# 法術（MagicData）
var magics: Array[MagicData] = []

# 玩家當前擁有的從者實例（ActiveMinion，帶等級與進化狀態）
var active_minions: Array[ActiveMinion] = []


# ── 道具操作 ─────────────────────────────────────────────
func add_item(data: ItemData) -> void:
	if data == null:
		push_error("InventoryManager.add_item: data 為 null")
		return
	items.append(data)
	item_added.emit(data)


func remove_item(data: ItemData) -> bool:
	var idx := items.find(data)
	if idx == -1:
		return false
	items.remove_at(idx)
	return true


# ── 法術操作 ─────────────────────────────────────────────
func add_magic(data: MagicData) -> void:
	if data == null:
		push_error("InventoryManager.add_magic: data 為 null")
		return
	magics.append(data)
	magic_added.emit(data)


func remove_magic(data: MagicData) -> bool:
	var idx := magics.find(data)
	if idx == -1:
		return false
	magics.remove_at(idx)
	return true


# ── 從者操作 ─────────────────────────────────────────────
func add_active_minion(minion: ActiveMinion) -> void:
	if minion == null:
		push_error("InventoryManager.add_active_minion: minion 為 null")
		return
	active_minions.append(minion)
	minion_added.emit(minion)


func remove_active_minion(minion: ActiveMinion) -> bool:
	var idx := active_minions.find(minion)
	if idx == -1:
		return false
	active_minions.remove_at(idx)
	return true


# ── 查詢 ─────────────────────────────────────────────────
func get_items() -> Array[ItemData]:
	return items

func get_magics() -> Array[MagicData]:
	return magics

func get_active_minions() -> Array[ActiveMinion]:
	return active_minions
