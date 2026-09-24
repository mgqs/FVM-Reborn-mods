// 用户事件11：发射海胆子弹
// 赖皮蛇按形态生成 1/2/3 发子弹，沿当前行向右飞到最右列再返回
for (var i = 0; i < bullet_count; i++)
{
    var inst = instance_create_depth(x, y - 40, depth - 500, obj_laipishe_bullet);
    inst.damage = atk;
    inst.owner_card = id;
    inst.start_col = grid_col;
    inst.start_row = grid_row;
    inst.bullet_shape = shape;
    inst.move_speed = 6;

    // 多子弹时稍微错开起点，避免完全重叠
    if (bullet_count > 1)
    {
        var _offset = (i - (bullet_count - 1) / 2) * 14;
        inst.y += _offset;
    }

    // 记录子弹引用，便于卡片销毁时清理
    if (ds_exists(laipishe_bullets, ds_type_list))
        ds_list_add(laipishe_bullets, inst.id);
}