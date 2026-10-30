/// @description 顽皮龙 - 鼠标左键按下（激活技能）
// 仅在空闲状态且冷却完成时才能激活技能
if (wanpilong_state != WANPILONG_STATE.IDLE)
    exit;

// 检查是否有足够的火苗（耗能100）
if (variable_global_exists("player_flame") && global.player_flame < wanpilong_cost)
{
    // 火苗不足，无法激活
    // 可以加一个提示
    exit;
}

// 扣除耗能（预留）
if (variable_global_exists("player_flame"))
    global.player_flame -= wanpilong_cost;

// 进入第一段选点
wanpilong_state = WANPILONG_STATE.TARGETING_SOURCE;
cast_resolved = false;
cast_cancelled = false;
