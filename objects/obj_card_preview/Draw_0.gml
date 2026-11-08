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

    // 双子百变蛇（二转）：再画「同列上一格 / 下一格」两格虚影，指示变身时会一起放下 3 张
    //   （2026-11-08 用户口径：虚影是**放卡时**的指示，不是变身之后才冒出来）
    if (card_id == "baibianshe" && preview_shape == 2) {
        var _g = get_grid_position_from_world(logical_base_x, logical_base_y);
        for (var _d = -1; _d <= 1; _d += 2) {
            var _rr = _g.row + _d;
            if (_rr < 0 || _rr >= global.grid_rows) continue;
            var _w = get_world_position_from_grid(_g.col, _rr);
            draw_sprite_ext(preview_sprite, 0, _w.x + platform_shift_x, _w.y + platform_shift_y, 1.8, 1.8, 0, c_white, 0.5);
        }
    }
} else {
    //draw_sprite_ext(preview_sprite, 0, draw_pos_x, draw_pos_y, 1.8, 1.8, 0, c_red, 0.3);
}

// 绘制实体预览（跟随鼠标）
draw_sprite_ext(preview_sprite, 0, x, y,1.8,1.8,0,c_white,1);
}