extends GMstate

# 此状态负责战斗前的“终极初始化”：
# 1. 重置基地与 UI。
# 2. 注入启动资金与银行初始化。
# 3. 瞬间流转至 play 状态。

func enter_state():
	# --- 1. 战场清理与重置 (Field Reset) ---
	# 强制清理旧的基地塔，防止由于上一局未清理干净导致的“多基地”Bug
	gm.clear_board_by_group("base_tower")
	# 重置顶部血条 UI 到 100% 状态
	gm.reset_top_bar()
	gm.reset_all_buttons_cd()
	
	# --- 2. 核心实体生成 (Base Spawning) ---
	# 在固定位置生成双方大本营
	gm.spawn_base("ally")
	gm.spawn_base("enemy")
	
	# --- 3. 经济系统注入 (Economy Injection) ---
	# 为玩家发放本局初始资金，并根据逻辑处理银行等级（通常是等级-1或重置）
	if gm.ms.has_method("start_level"):
		gm.ms.start_level()
	else:
		push_error("PrepState: Money_system 缺失 start_level 方法")
	
	# --- 4. 状态自动流转 (Transition) ---
	# 准备工作在同一帧完成，直接进入正式战斗阶段
	gm.es.reset_wave_timer()
	gm_state_machine.switch_state("play")
	
	gm.reset_all_buttons_cd()

func end_state():
	# 准备阶段通常不需要复杂的清理逻辑
	pass
