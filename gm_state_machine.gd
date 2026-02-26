extends Node

#region description
#这段代码实现了一个非常标准且极为优雅的分层状态机（Hierarchical State Machine）。如果说 Game Manager (GM) 是整个游戏的“大脑”，那么这个状态机就是大脑里的“意识控制中心”，它负责在任何给定的时刻，决定游戏当前处于什么大阶段（比如：准备阶段、战斗阶段、结算阶段）。
#
#从整体设计来看，这个脚本展现了极高的代码素养，主要体现在以下四个核心机制：
#
#1. 自动化的依赖注入与映射 (Automated Assembly & Injection)
#在 _ready 函数中，这个状态机展现了非常聪明的“自组装”能力。它不仅自动遍历了挂载在它下面的所有子节点（即各个具体的 State 脚本），并将它们按名字注册到 state_map 字典中，最绝的是，它主动把大管家 gm 和状态机自身的引用赋值给了这些子状态。这意味着：具体的子状态脚本再也不用写复杂的 get_parent() 来找组织了，它们天生就知道自己的老大是谁。
#
#2. 绝对解耦的全局信号响应 (Global Decoupling)
#通过监听 SignalBus.gm_switch_state 信号，这个状态机彻底实现了逻辑上的解耦。无论你在游戏的哪个角落（哪怕是一个 UI 按钮，或者是一个怪物死掉时的判定），只要向总线发送这个信号，GM 的状态机就能立刻响应并切换游戏阶段。这让你以后扩展游戏流程变得无比轻松。
#
#3. 严谨的生命周期交接 (Strict Lifecycle Management)switch_state 函数是整个状态机的灵魂交接仪式。它严格遵循了“先旧后新”的安全原则：在进入新状态的 enter_state() 之前，必定会先调用上一个状态的 end_state() 进行收尾工作（比如清理临时 UI、重置计时器）。这种设计彻底杜绝了状态切换时常常出现的“上一个状态的残留 Bug”。
#
#4. 代理执行引擎 (Delegated Processing)single_state_process 函数充当了一个“代理路由器”。当外部（通常是 GM 的 _process）每一帧呼叫状态机时，状态机自己不执行任何具体逻辑，而是直接把这帧的执行权原封不动地抛给当前激活状态的 state_process()。这保证了在同一时间，只有唯一一套规则在驱动游戏运行。
#endregion

var current_state :String= ""
@export var default_state:String = ""


var state_map = {}



func _ready() -> void:
	SignalBus.gm_switch_state.connect(switch_state)
	await get_tree().process_frame
	var gm = get_parent()
	for s in get_children():
		state_map[s.state_name] = s
		s.gm = gm
		s.gm_state_machine = self
	switch_state(default_state)
	

func switch_state(state_name):
	print("enter: ",state_name)
	if current_state !="":
		state_map[current_state].end_state()
	current_state = state_name
	state_map[current_state].enter_state()
	pass

func single_state_process():
	state_map[current_state].state_process()
