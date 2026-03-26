extends GMstate

const SHOP_WINDOW_SCENE = preload("res://scene/shop_window.tscn")

## 從編輯器指定商店池資源
@export var pool: ShopPool
## 每次開店隨機展示的商品數量
@export var draw_count: int = 5

var _window: Control = null


func enter_state() -> void:
	var drawn: Array = []
	if pool != null:
		# duplicate 保留原始池不被消耗，每次重新開店都有完整商品
		var working_pool: ShopPool = pool.duplicate(true)
		drawn = working_pool.draw_random(draw_count)
	else:
		push_warning("ShopState: pool 未指定，商店將顯示為空")

	_window = SHOP_WINDOW_SCENE.instantiate()
	gm.cl.add_child(_window)
	_window.setup(drawn, gm)


func end_state() -> void:
	if is_instance_valid(_window):
		_window.queue_free()
	_window = null
