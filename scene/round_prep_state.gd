extends GMstate

#region description
#核心执行流：
#
#实体防错清理：调用 clear_board_by_group("base_tower") 强制销毁场上残留的双方主基地，杜绝重复生成的 Bug。
#
#核心目标生成：通过 spawn_base 重新实例化玩家（ally）与敌人（enemy）的大本营，确立当前波次的胜负节点。
#
#经济系统注入：调用 Money_system 的 start_level()，为玩家发放本局的初始启动资金并初始化银行等级。
#
#状态直接流转：以上指令在同一帧内执行完毕后，无任何阻塞或等待，立即调用状态机切换至 "play"（正式战斗）状态。
#endregion



func enter_state():
	gm.clear_board_by_group("base_tower")
	gm.spawn_base("ally")
	gm.spawn_base("enemy")
	gm.ms.start_level()
	gm_state_machine.switch_state("play")
