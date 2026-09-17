var _x = x;
var _y = y;

if (variable_instance_exists(id, "hitted_enemy") && instance_exists(hitted_enemy))
{
    _x = hitted_enemy.x;
    _y = hitted_enemy.y;
}

var splash_ratio = 0.45;

if (shape >= 1)
    splash_ratio = 0.5;

with (obj_enemy_parent)
{
    if (hp > 0 && abs(_x - x) < 150 && abs(grid_row - other.row) <= 1)
    {
        var is_direct_hit = false;
        
        if (variable_instance_exists(other, "hitted_enemy"))
        {
            if (id == other.hitted_enemy)
                is_direct_hit = true;
        }
        
        if (!is_direct_hit && can_hit(other.target_type, target_type))
        {
            if (other.shape <= 1 || hp > (other.damage * splash_ratio))
            {
                damage_amount = other.damage * splash_ratio;
                damage_type = other.damage_type;
                event_user(0);
            }
            else
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
}
