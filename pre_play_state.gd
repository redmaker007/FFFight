extends GMstate

#region description
#1. 物理断电与系统冻结 (System Freeze)
#一进入这个状态，它首先拉下了 Game Manager 的“总电闸”（关闭了所有核心子系统）。这确保了在重置的这短暂瞬间，绝对不会有任何残留的刷怪逻辑、攻击判定或是金币增长在后台偷偷运行捣乱。整个动态的游戏世界被瞬间强行静止。
#
#2. 资产与盘面的绝对清空 (Absolute Wipe)
#紧接着，它执行了无情的“双清”操作。一方面，它清空了玩家的口袋，将经济系统（银行等级、金币储备）彻底归零还原；另一方面，它呼叫大管家施展了全屏抹除，把棋盘上所有的残存实体（无论是上一局的防御塔、怪物还是尸体）全部清理掉。这保证了每一次新开局都处于绝对公平、毫无干扰的纯净态。
#
#3. 极速的跳板跃迁 (Trampoline Transition)
#最干脆利落的是它的收尾。这个状态完全不需要停留等待，也没有任何需要每帧运行的逻辑。它就像一块高弹力的“跳板”，在执行完上面这些保洁工作后，立刻将执行权强行切换给了下一个状态——"hex"（推测是进入六边形网格地图的生成或铺设阶段）。
#endregion

func enter_state():
	gm.group_switch_func(false)
	gm.ms.reset_bank()
	gm.clear_board()
	gm.hs.clear_hex()
	
	gm.em_reset_count()
	gm.reset_top_bar()
	gm_state_machine.switch_state("hex")
	
	
