// 三档（初级/深度/灵魂）的落地灼烧范围统一为 3×3（col ±1、row ±1）
var row_offset = 1;
var col_offset = 1;

with (obj_enemy_parent)
{
    if (grid_col >= (other.grid_col - col_offset) && grid_col <= (other.grid_col + col_offset) && abs(grid_row - other.grid_row) <= row_offset && can_hit(other.target_type, target_type) && hp > 0)
    {
        var _prev_hp = hp;
        damage_amount = other.damage;
        damage_type = other.damage_type;
        event_user(0);

        if (_prev_hp > 0 && hp <= 0)
        {
            if (special_ash)
            {
                var inst = instance_create_depth(x, y - 20, depth, obj_mouse_ash_death);
                inst.special_ash = true;
                inst.sprite_index = sprite_index;
                inst.image_index = image_index;
            }
            else
            {
                instance_create_depth(x, y - 20, depth, obj_mouse_ash_death);
            }

            instance_destroy();
        }
    }
}
