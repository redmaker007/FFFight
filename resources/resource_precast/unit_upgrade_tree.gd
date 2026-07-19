class_name UnitUpgradeTree
extends Resource

## 升級樹。root.payload 必須是 minion_data。
@export var root: UpgradeTreeNode

# ── 樹操作方法 ───────────────────────────────────────────────────────────────

## 在 parent 節點下新增一個子節點。
## 如果 parent 為 null，則新增至 root 的直接子節點。
func add_node(payload: Resource, parent: UpgradeTreeNode = null) -> UpgradeTreeNode:
	var node := UpgradeTreeNode.new()
	node.payload = payload
	if parent == null:
		root.children.append(node)
	else:
		parent.children.append(node)
	return node

## DFS 搜尋：找到 payload 完全相同（同一 Resource 實例）的節點，找不到回傳 null。
func find_node(target_payload: Resource) -> UpgradeTreeNode:
	return _dfs_find(root, target_payload)

func _dfs_find(node: UpgradeTreeNode, target: Resource) -> UpgradeTreeNode:
	if node == null:
		return null
	if node.payload == target:
		return node
	for child in node.children:
		var result := _dfs_find(child, target)
		if result != null:
			return result
	return null

## 取得從 root 到目標節點的完整路徑（含兩端）。找不到回傳空陣列。
func get_path_to(target_payload: Resource) -> Array[UpgradeTreeNode]:
	var path: Array[UpgradeTreeNode] = []
	if _dfs_path(root, target_payload, path):
		return path
	return []

func _dfs_path(node: UpgradeTreeNode, target: Resource, path: Array[UpgradeTreeNode]) -> bool:
	if node == null:
		return false
	path.append(node)
	if node.payload == target:
		return true
	for child in node.children:
		if _dfs_path(child, target, path):
			return true
	path.pop_back()
	return false

## DFS 展平：回傳樹中所有節點的陣列（先序）。
func get_all_nodes() -> Array[UpgradeTreeNode]:
	var result: Array[UpgradeTreeNode] = []
	_dfs_collect(root, result)
	return result

func _dfs_collect(node: UpgradeTreeNode, result: Array[UpgradeTreeNode]) -> void:
	if node == null:
		return
	result.append(node)
	for child in node.children:
		_dfs_collect(child, result)

## 取得所有葉節點（沒有子節點的節點）。
func get_all_leaves() -> Array[UpgradeTreeNode]:
	return get_all_nodes().filter(func(n): return n.is_leaf())
