// 用户事件11：发射海胆子弹
// 三段式弹道：卡片→右下角→沿最右列从下往上→右上角→返回卡片销毁
//
// 最右列只扫 **第 10 列**（combat_max_col = 敌人出生点列，也是 BOSS 常驻的格子）。
// 第 9 列（地图最右一格）不再生成弹道：双列并存时两道平行轨迹只隔一格，
// 视觉上像"多打了一条"，且会让同批老鼠吃到双份伤害。
// 数组形式保留（只含一个元素），以后若要恢复双列只需把 grid_cols-1 加回来。
var _right_cols = [combat_max_col()];
for (var _ci = 0; _ci < array_length(_right_cols); _ci++)
{
    var _right_col = _right_cols[_ci];
    if (_ci > 0 && _right_col == _right_cols[0]) continue;   // grid_cols 异常时不重复生成

    for (var _bi = 0; _bi < bullet_count; _bi++)
    {
        var inst = instance_create_depth(x, y, depth - 500, obj_laipishe_bullet);
        inst.damage = atk * damage_multiplier;
        inst.owner_card = id;
        inst.bullet_shape = shape;
        inst.move_speed = 6;

        // 卡片位置作为起点和返回点
        inst.start_x = x;
        inst.start_y = y;

        // 路径点1：右下角（该列最后一行格子，子弹底部对齐到格子下边）
        var _wp1 = get_world_position_from_grid(_right_col, global.grid_rows - 1);
        inst.wp1_x = _wp1.x;
        inst.wp1_y = _wp1.y + global.grid_cell_size_y / 2 - sprite_get_height(spr_laipishe_bullet) * inst.image_yscale / 2;

        // 路径点2：右上角（该列第一行格子的上边）
        var _wp2 = get_world_position_from_grid(_right_col, 0);
        inst.wp2_x = _wp2.x;
        inst.wp2_y = _wp2.y - global.grid_cell_size_y / 2;

        // 多子弹时稍微错开起点，避免完全重叠
        if (bullet_count > 1)
        {
            var _offset = (_bi - (bullet_count - 1) / 2) * 14;
            inst.y += _offset;
            inst.start_y += _offset;
        }

        // 记录子弹引用，便于卡片销毁时清理
        if (ds_exists(laipishe_bullets, ds_type_list))
            ds_list_add(laipishe_bullets, inst.id);
    }
}
