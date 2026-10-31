// obj_tangchaolizi_bullet_effect（落地灼烧）结算事件
// 范围：0 转 = 3×3 十字（同排 ±1 格 或 上下同列）；1、2 转 = 3×3 全格（一转能力：范围扩大到 3×3）
// 伤害走 damage_amount + event_user(0)，这样才会进测试关的伤害统计（击杀出灰烬）。
var _cross = (shape < 1);

with (obj_enemy_parent)
{
    var _in = _cross
        ? ((grid_row == other.grid_row && abs(grid_col - other.grid_col) <= 1)
           || (grid_col == other.grid_col && abs(grid_row - other.grid_row) <= 1))
        : (abs(grid_row - other.grid_row) <= 1 && abs(grid_col - other.grid_col) <= 1);

    if (_in && hp > 0 && can_hit(other.target_type, target_type))
    {
        var _prev_hp = hp;
        damage_amount = other.damage;
        damage_type = other.damage_type;
        event_user(0);

        if (_prev_hp > 0 && hp <= 0)
        {
            if (special_ash)
            {
                var _ash = instance_create_depth(x, y - 20, depth, obj_mouse_ash_death);
                _ash.special_ash = true;
                _ash.sprite_index = sprite_index;
                _ash.image_index = image_index;
            }
            else
            {
                instance_create_depth(x, y - 20, depth, obj_mouse_ash_death);
            }
            instance_destroy();
        }
    }
}
