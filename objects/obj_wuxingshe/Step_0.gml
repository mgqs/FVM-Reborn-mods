// obj_wuxingshe（五行蛇）Step 事件
// 只做两件事：① 维护五向增幅网格（被挪位置要重建）；② 光环跟随本体。
// 本体不索敌、不攻击，动画停在闲置循环。
if (global.is_paused) exit;

event_inherited();
if (hp <= 0) exit;

if (!buff_cells_refreshed)
{
    buff_value = atk / 100;
    ds_list_add(global.buff_sources, id);
    refresh_buff_cells();
    global.buff_dirty = true;
    buff_cells_refreshed = true;
    last_buff_col = grid_col;
    last_buff_row = grid_row;
}
else if (grid_col != last_buff_col || grid_row != last_buff_row)
{
    buff_value = atk / 100;
    refresh_buff_cells();
    global.buff_dirty = true;
    last_buff_col = grid_col;
    last_buff_row = grid_row;
}

// 光环跟随（被木板/铲子挪动时也要跟着走）
for (var i = 0; i < array_length(wuxingshe_effects); i++) {
    var _e = wuxingshe_effects[i];
    if (instance_exists(_e)) {
        _e.x = x + 6;              // 法阵往右 6px（与 Create 的 _fx_dx 保持一致）
        _e.y = y - 20;             // 法阵往上 20px（与 Create 的 _fx_dy 保持一致）
        _e.depth = depth + 10;     // 始终压在卡片下层（卡片 depth 由 calculate_plant_depth 决定）
    }
}

wuxingshe_age++;
