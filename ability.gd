extends Node

var ability_name = "empty"

var ability_map = {
	"apply_slow":[Callable(self,"apply_slow"),"on_attack"],
	"empty":[Callable(self,"empty"),"null"]
}



#常規觸發前提
func on_spawn(owner): pass
func on_attack(owner, target): 
	if ability_map[ability_name][1] == "on_attack" and target:
		ability_map[ability_name][0].call(target)
func on_hit(owner, target): pass
func on_death(owner): pass




#能力方法
func apply_slow(target):
	target.apply_debuff("slow",1)

func empty(target):
	pass
