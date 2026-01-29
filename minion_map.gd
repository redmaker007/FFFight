extends Node

var mm = {
	"base":{
		"name"="base",
		
		"speed" = 0,
		"max_hp" = 2000,
		"att" = 0,
		"att_r" = 0,
		"att_CD" = 9999,
		"image" = preload("res://empty.png"),
		"size" = 1
	},
	"red":{
		"name"="red",
		
		"speed" = 40,
		"max_hp" = 500,
		"att" = 10,
		"att_r" = 30,
		"att_CD" = 1,
		"image" = preload("res://minion.png"),
		"size" = 0.2
	},
	"blue":{
		"name"="blue",
		
		"speed" = 120,
		"max_hp" = 100,
		"att" = 11,
		"att_r" = 50,
		"att_CD" = 0.33,
		"image" = preload("res://binion.png"),
		"size" = 0
	},
	"boxer":{
		"name"="boxer",
		
		"speed" = 40,
		"max_hp" = 130,
		"att" = 55,
		"att_r" = 50,
		"att_CD" = 0.4,
		"image" = preload("res://boxer.png"),
		"size" = 0
	},
	"snow_ball_shooter":{
		"name"="snow_ball_shooter",
		
		"speed" = 70,
		"max_hp" = 100,
		"att" = 22,
		"att_r" = 250,
		"att_CD" = 1.1,
		"image" = preload("res://snow_b_s.png"),
		"size" = -0.1
	}
}
