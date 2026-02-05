extends Node

var mm :Dictionary= {
	"base":{
		"name"="base",
		
		"cost"= 0,
		
		"speed" = 0,
		"max_hp" = 2000,
		"att" = 0,
		"att_r" = 0,
		"att_CD" = 9999,
		"image" = preload("res://art/empty.png"),
		"size" = 1,
		
		"ability" = ["empty"],
	},
	"super_boss":{
		"name"="super_boss",
		
		"cost"= 25,
		
		"speed" = 400,
		"max_hp" = 999,
		"att" = 200,
		"att_r" = 100,
		"att_CD" = 0.2,
		"image" = preload("res://art/minion.png"),
		"size" = 0.5,
		
		"ability" = ["empty"],
	},
	"red":{
		"name"="red",
		
		"cost"= 25,
		
		"speed" = 40,
		"max_hp" = 250,
		"att" = 15,
		"att_r" = 30,
		"att_CD" = 1,
		"image" = preload("res://art/minion.png"),
		"size" = 0.2,
		
		"ability" = ["empty"],
	},
	"blue":{
		"name"="blue",
		
		"cost"= 15,
		
		"speed" = 100,
		"max_hp" = 60,
		"att" = 5,
		"att_r" = 50,
		"att_CD" = 0.9,
		"image" = preload("res://art/binion.png"),
		"size" = 0,
		
		"ability" = ["empty"],
	},
	"boxer":{
		"name"="boxer",
		
		"cost"= 40,
		
		"speed" = 40,
		"max_hp" = 180,
		"att" = 50,
		"att_r" = 50,
		"att_CD" = 0.7,
		"image" = preload("res://art/boxer.png"),
		"size" = 0,
		
		"ability" = ["empty"],
	},
	"snow_ball_shooter":{
		"name"="snow_ball_shooter",
		
		"cost"= 70,
		
		"speed" = 70,
		"max_hp" = 80,
		"att" = 20,
		"att_r" = 250,
		"att_CD" = 0.6,
		"image" = preload("res://art/snow_b_s.png"),
		"size" = -0.1,
		
		"ability" = ["apply_slow"],
	}
}
