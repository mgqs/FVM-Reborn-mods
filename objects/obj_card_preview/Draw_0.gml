// obj_plant_preview DRAW 事件

if not global.is_paused{
    if (!variable_instance_exists(id, "logical_base_x")) {
        logical_base_x = x;
        logical_base_y = y;
        platform_shift_x = 0;
        platform_shift_y = 0;
    }

// 绘制地面上的半透明预览
var grid_pos = get_nearest_grid_position(logical_base_x, logical_base_y); // 获取最近的网格位置
var draw_pos_x = grid_pos.x + platform_shift_x;
var draw_pos_y = grid_pos.y + platform_shift_y;
if (is_valid) {
    draw_sprite_ext(preview_sprite, 0, draw_pos_x, draw_pos_y, 1.8, 1.8, 0, c_white, 0.5);

    // 双子百变蛇（二转）：再画「同列上一格 / 下一格」两格虚影，指示放下时会一起占 3 格
    //   （2026-11-08 用户口径：虚影是**放卡时**的指示，不是变身之后才冒出来）
    //   2026-11-12 修：虚影必须与实放位置一致 ——
    //     ① 边路没有那一行时行号 clamp 到最边行，不再直接跳过（原来会少画一只）；
    //     ② 目标格被占就按同列→同行→斜角、半径 ≤2 由近到远挤到最近可放格；
    //     ③ 已用格子记进 _used，避免两只虚影叠在同一格。
    if (card_id == "baibianshe" && preview_shape == 2) {
        var _g = get_grid_position_from_world(logical_base_x, logical_base_y);
        var _used = {};
        _used[$ string(_g.col) + "_" + string(_g.row)] = true;
        for (var _d = -1; _d <= 1; _d += 2) {
            var _want_r = clamp(_g.row + _d, 0, global.grid_rows - 1);
            var _cell = baibianshe_preview_cell(_g.col, _want_r, 2, _used);
            if (array_length(_cell) == 0) continue;
            _used[$ string(_cell[0]) + "_" + string(_cell[1])] = true;
            var _w = get_world_position_from_grid(_cell[0], _cell[1]);
            draw_sprite_ext(preview_sprite, 0, _w.x + platform_shift_x, _w.y + platform_shift_y, 1.8, 1.8, 0, c_white, 0.5);
        }
    }
} else {
    //draw_sprite_ext(preview_sprite, 0, draw_pos_x, draw_pos_y, 1.8, 1.8, 0, c_red, 0.3);
}

// 绘制实体预览（跟随鼠标）
draw_sprite_ext(preview_sprite, 0, x, y,1.8,1.8,0,c_white,1);
}