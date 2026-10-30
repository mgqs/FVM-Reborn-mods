// Keep the collision mask at native size while preserving each bullet's visual scale.
if (!variable_instance_exists(id, "visual_scale_x"))
{
    visual_scale_x = 1;
    visual_scale_y = 1;
}

if (image_xscale != 1 || image_yscale != 1)
{
    visual_scale_x = image_xscale;
    visual_scale_y = image_yscale;
}

image_xscale = 1;
image_yscale = 1;

// 海克斯「碎片整理」：多行攻击卡（三线类等）的子弹全部收敛到本行。
// 只在子弹带 target_row（多行弹专有字段）且向右飞时生效，别的一律不动。
// 注意：obj_bullet_parent 本身没有 row 字段，巧克力炮之类只有 target_col/target_row，
// 所以不能直接写 target_row = row，必须按字段存在与否分成两条路。
if (hex_batch2_bull_row() && variable_instance_exists(id, "target_row")) {
    var _go_right = true;
    if (variable_instance_exists(id, "move_speed")) _go_right = (move_speed >= 0);
    if (_go_right) {
        if (variable_instance_exists(id, "row")) {
            target_row = row;
        } else {
            var _gp = get_grid_position_from_world(x, y);
            if (!is_undefined(_gp)) target_row = _gp.row;
        }
    }
}
