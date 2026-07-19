class_name ActiveMinion
extends Resource

signal leveled_up(new_level: int)
signal node_changed(node: UpgradeTreeNode)

# 升級樹（正式資料來源）
@export var tree: UnitUpgradeTree

# 當前在樹中所在的節點（從 root 出發，選擇升級後向下移動）
@export var current_node: UpgradeTreeNode

# 當局狀態
@export var current_level: int = 1
@export var experience: int = 0

# TODO: 當局增益效果清單 (Buff List)
# 預計結構：@export var active_buffs: Array[stat_mod]
# 由 Hex 效果的 give_target_stat、grant_ability_hex 等寫入

## 取得當前有效的 minion_data。
## current_node 指向 minion_data 節點時回傳該節點的資料（進化後形態）；
## current_node 指向 UnitStatUpgrade 節點時 fallback 至 root（尚未進化）。
var data: minion_data:
	get:
		if current_node != null and current_node.payload is minion_data:
			return current_node.payload as minion_data
		if tree == null or tree.root == null:
			return null
		return tree.root.payload as minion_data

# ── 初始化 ───────────────────────────────────────────────────────────────────

## 從一個 minion_data 建立（自動生成只含 root 的最小樹）。
## 用於開局預設單位時。
func init_with_data(md: minion_data) -> void:
	var node := UpgradeTreeNode.new()
	node.payload = md
	var t := UnitUpgradeTree.new()
	t.root = node
	tree = t
	current_node = node

## 從一個已有的 UnitUpgradeTree 建立（商店購買時使用）。
func init_with_tree(t: UnitUpgradeTree) -> void:
	tree = t
	current_node = t.root

# ── 升級系統 ─────────────────────────────────────────────────────────────────

## 增加經驗值，滿 10 點自動升級（上限 Lv.3）
func add_experience(amount: int) -> void:
	if current_level >= 3:
		return
	experience += amount
	if experience >= 10:
		experience -= 10
		current_level += 1
		leveled_up.emit(current_level)

# ── 屬性查詢 ─────────────────────────────────────────────────────────────────

## 取得 root → current_node 路徑上所有已激活的 UnitStatUpgrade 詞條。
func get_active_stat_upgrades() -> Array[UnitStatUpgrade]:
	if tree == null or current_node == null:
		return []
	var path := tree.get_path_to(current_node.payload)
	var result: Array[UnitStatUpgrade] = []
	for n in path:
		if n.is_stat_upgrade():
			result.append(n.payload as UnitStatUpgrade)
	return result

## 取得屬性數值。
## 初步邏輯直接返回 root minion_data 中的基礎值；
## 未來可在此疊算 current_node 路徑上的 UnitStatUpgrade 加成。
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
