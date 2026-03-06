extends Node

var unit_dic:Dictionary







func _ready() -> void:
	register(preload("res://resources/minion/blue.tres"))
	register(preload("res://resources/minion/boxer.tres"))
	register(preload("res://resources/minion/butterfly_kun.tres"))
	register(preload("res://resources/minion/red.tres"))
	register(preload("res://resources/minion/snow_ball_shooter.tres"))
	register(preload("res://resources/minion/super_boss.tres"))
	register(preload("res://resources/minion/base.tres"))
	register(preload("res://resources/minion/soulblade.tres"))


func register(md:minion_data):
	unit_dic[md.minion_id] = md
	
	
	
	pass
