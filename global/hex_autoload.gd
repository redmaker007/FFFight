extends Node

var hex_dic ={}



func _ready() -> void:
	register(preload("res://resources/hex/hex_1.tres"))
	register(preload("res://resources/hex/hex_2.tres"))
	register(preload("res://resources/hex/hex_3.tres"))
	register(preload("res://resources/hex/hex_4.tres"))
	pass
	
	
	
func register(h:hex_data):
	hex_dic[h.hex_id] = h
	pass
