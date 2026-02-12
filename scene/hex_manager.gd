extends Node

@onready var gm = get_parent()

var active_hex_list = []

func _ready() -> void:
	SignalBus.unit_spawned.connect(active_unit_spawn_hex)
	pass

func add_hex(h:sub_hex_data):
	var ref = active_hex.new()
	ref.data = h
	active_hex_list.append(ref)

func active_all_hex():
	if active_hex_list.is_empty():

		return
	for h in active_hex_list:
		if h.data.has_method("hex_process"):
			
			h.data.hex_process(gm)


func deactive_all_hex():
	if active_hex_list.is_empty():
		return
	var temp_l = []
	for h in active_hex_list:
		if h.data.one_time:
			temp_l.append(h)
		if h.data.has_method("hex_process_take_back"):
			h.data.hex_process_take_back(gm)
	for h in temp_l:
		active_hex_list.erase(h)

func active_unit_spawn_hex(unit):
	if active_hex_list.is_empty():
		return
	for h in active_hex_list:
		if h.data.has_method("on_unit_spawn"):
			h.data.on_unit_spawn(unit)
