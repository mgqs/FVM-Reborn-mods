/// @description 顽皮龙 - 销毁事件
event_inherited();

// 清理高亮列表
if (variable_instance_exists(id, "highlight_cells") && ds_exists(highlight_cells, ds_type_list))
    ds_list_destroy(highlight_cells);

// 如果正在选点状态，返还耗能
if (wanpilong_state == WANPILONG_STATE.TARGETING_SOURCE ||
    wanpilong_state == WANPILONG_STATE.PRE_SWING ||
    wanpilong_state == WANPILONG_STATE.TARGETING_DEST)
{
    if (!cast_resolved && !cast_cancelled)
    {
        if (variable_global_exists("player_flame"))
            global.player_flame += wanpilong_cost;
    }
}

// 清除全局激活标记
if (variable_global_exists("wanpilong_active_id") && global.wanpilong_active_id == id)
    global.wanpilong_active_id = noone;
