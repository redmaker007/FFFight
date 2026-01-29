extends Node

var mm = {
	"base":{
		"name"="base",
		
		"cost"= 0,
		
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
		
		"cost"= 15,
		
		"speed" = 40,
		"max_hp" = 250,
		"att" = 10,
		"att_r" = 30,
		"att_CD" = 1,
		"image" = preload("res://minion.png"),
		"size" = 0.2
	},
	"blue":{
		"name"="blue",
		
		"cost"= 10,
		
		"speed" = 100,
		"max_hp" = 80,
		"att" = 6,
		"att_r" = 50,
		"att_CD" = 0.6,
		"image" = preload("res://binion.png"),
		"size" = 0
	},
	"boxer":{
		"name"="boxer",
		
		"cost"= 35,
		
		"speed" = 40,
		"max_hp" = 180,
		"att" = 50,
		"att_r" = 50,
		"att_CD" = 0.7,
		"image" = preload("res://boxer.png"),
		"size" = 0
	},
	"snow_ball_shooter":{
		"name"="snow_ball_shooter",
		
		"cost"= 50,
		
		"speed" = 70,
		"max_hp" = 80,
		"att" = 35,
		"att_r" = 250,
		"att_CD" = 0.5,
		"image" = preload("res://snow_b_s.png"),
		"size" = -0.1
	}
}
