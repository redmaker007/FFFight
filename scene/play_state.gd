extends GMstate


#region description

#Play (战斗) 状态整体解析
#此状态是游戏的主干环节，负责驱动实际的波次防守、经济运转与战斗过程。
#
#核心执行流：
#
#系统全面激活 (enter_state)：调用大管家的 group_switch_func(true) 开启总闸，正式启动双方兵力生成（Unit/Enemy Spawner）以及金币系统的自动累加。
#
#胜负监听挂载 (enter_state)：订阅全局信号 SignalBus.unit_death，用于实时监控关键建筑（基地）的存亡。
#
#安全退出清理 (end_state)：在退出该状态时，严谨地断开死亡信号连接，防止内存泄漏或在其他状态下触发幽灵判定。
#
#胜负逻辑仲裁 (check_base_death)：
#
#接收所有单位的死亡事件，过滤甄别死者是否为 "base"（主基地）。
#
#失败条件：若己方 (ally) 基地阵亡，触发败局，状态机切入 "gameover"。
#
#胜利条件：若敌方 (enemy) 基地阵亡，判定当前波次防守成功，状态机直接切回 "hex" 进入下一轮的战场构筑与词条抽取。
#
#系统定位：
#全盘激活游戏核心机制的运行态，同时作为胜负裁判官，决定战局走向（循环发育或游戏结束）。
#endregion

func enter_state():
	gm.group_switch_func(true)
	SignalBus.unit_death.connect(check_base_death)

func end_state():
	if SignalBus.unit_death.is_connected(check_base_death):
		SignalBus.unit_death.disconnect(check_base_death)

func check_base_death(unit):
	if unit.unit_name == "base":
		if unit.side == "ally":
			gm_state_machine.switch_state("gameover")
		else:
			gm_state_machine.switch_state("hex")
