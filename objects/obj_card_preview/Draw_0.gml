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

    // 双子百变蛇（二转）：再画另外两格虚影，指示放下时会一起占 3 格
    //   （2026-11-08 用户口径：虚影是**放卡时**的指示，不是变身之后才冒出来）
    //   2026-11-12：虚影与实放**共用同一套排布**（scripts/baibianshe_preview_cell →
    //     baibianshe_layout_cells）—— 九宫格口径：2/8 优先，某一侧被挡就在那一行的左右（1/3 或 7/9），
    //     2 和 8 都被挡才横排（4/6），3×3 全满才远距离兜底。这样虚影永远不会和实际落点不一致。
    if (card_id == "baibianshe" && preview_shape == 2) {
        var _g = get_grid_position_from_world(logical_base_x, logical_base_y);
        var _used = {};
        _used[$ string(_g.col) + "_" + string(_g.row)] = true;
        var _cells = baibianshe_layout_cells(_g.col, _g.row, _used);
        for (var _ci = 0; _ci < array_length(_cells); _ci++) {
            var _w = get_world_position_from_grid(_cells[_ci][0], _cells[_ci][1]);
            draw_sprite_ext(preview_sprite, 0, _w.x + platform_shift_x, _w.y + platform_shift_y, 1.8, 1.8, 0, c_white, 0.5);
        }
    }
} else {
    //draw_sprite_ext(preview_sprite, 0, draw_pos_x, draw_pos_y, 1.8, 1.8, 0, c_red, 0.3);
}

// 绘制实体预览（跟随鼠标）
draw_sprite_ext(preview_sprite, 0, x, y,1.8,1.8,0,c_white,1);
}