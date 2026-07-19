class_name UpgradeTreeNode
extends Resource

## 樹節點的內容。
## - root 層：必須是 minion_data
## - 其他層：minion_data（進化分支）或 UnitStatUpgrade（數值強化）
@export var payload: Resource

## 子節點，數量不限（multi-way tree）
@export var children: Array[UpgradeTreeNode] = []

# ── 查詢輔助 ────────────────────────────────────────────────────────────────

func is_leaf() -> bool:
	return children.is_empty()

func is_evolution() -> bool:
	return payload is minion_data

func is_stat_upgrade() -> bool:
	return payload is UnitStatUpgrade
