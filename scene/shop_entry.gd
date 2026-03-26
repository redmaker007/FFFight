extends PanelContainer

@onready var icon_rect: TextureRect = $VBox/Icon
@onready var name_label: Label     = $VBox/NameLabel
@onready var price_label: Label    = $VBox/PriceLabel
@onready var buy_btn: Button       = $VBox/BuyBtn

var _data: Resource
var _gm: Node


func setup(data: Resource, gm: Node) -> void:
	_data = data
	_gm  = gm

	var icon: Texture2D
	var display_name: String
	var price: int

	if data is minion_data:
		icon         = data.image
		display_name = data.get_name_key()
		price        = data.cost
	elif data is ItemData:
		icon         = data.icon
		display_name = data.get_display_name()
		price        = data.price
	elif data is MagicData:
		icon         = data.icon
		display_name = data.get_display_name()
		price        = data.price

	if icon:
		icon_rect.texture = icon
	name_label.text  = display_name
	price_label.text = tr("$") + str(price)
	buy_btn.text     = tr("BUY")
	buy_btn.pressed.connect(_on_buy)


func _on_buy() -> void:
	var price: int
	if _data is minion_data:
		price = _data.cost
	else:
		price = _data.price

	if _gm.ms.money_amount < price:
		_shake_btn()
		return

	_gm.ms.money_amount -= price
	_gm.ms.update_text()

	var inv: Node = _gm.get_node("Inventory_manager")
	if _data is ItemData:
		inv.add_item(_data)
	elif _data is MagicData:
		inv.add_magic(_data)
	elif _data is minion_data:
		var active := ActiveMinion.new()
		active.data = _data
		inv.add_active_minion(active)

	buy_btn.disabled = true
	buy_btn.text     = tr("SOLD")


func _shake_btn() -> void:
	var origin := buy_btn.position
	var tw := buy_btn.create_tween()
	tw.tween_property(buy_btn, "modulate", Color(1, 0.3, 0.3), 0.06)
	const D := 6.0
	for i in 4:
		tw.tween_property(buy_btn, "position:x", origin.x + (D if i % 2 == 0 else -D), 0.05)
	tw.tween_property(buy_btn, "position:x", origin.x, 0.05)
	tw.tween_property(buy_btn, "modulate", Color(1, 1, 1), 0.1)
