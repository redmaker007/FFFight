# corner.gd
extends Control

@export var color: Color = Color("#a08820")
@export var _size: float = 80.0

func _draw():
	# 垂直线
	draw_line(Vector2(0, 0), Vector2(0, _size), color, 2.0)
	# 水平线
	draw_line(Vector2(0, 0), Vector2(_size, 0), color, 2.0)
