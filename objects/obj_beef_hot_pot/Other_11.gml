var current_flash_speed = is_slowdown ? (flash_speed * 2) : flash_speed;

if (damage_timer == 0 || damage_timer >= (2 * current_flash_speed))
{
    damage_timer = 1;
    var max_col_offset = (shape < 2) ? 4 : 5;
    
    with (obj_enemy_parent)
    {
        if (hp > 0 && grid_row == other.grid_row && grid_col >= other.grid_col && grid_col <= (other.grid_col + max_col_offset))
        {
            if (can_target_on(other.target_type, target_type))
            {
                if (hp <= other.atk && !immune_to_ash)
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
                else
                {
                    damage_amount = other.atk;
                    damage_type = "pierce";
                    event_user(0);
                }
            }
        }
    }
}
else
{
    damage_timer++;
}
