if (global.is_paused)
{
    image_speed = 0;
    exit;
}

if (delay > 0)
{
    delay--;
    image_alpha = 0;
    image_speed = 0;
    
    if (instance_exists(target_id))
    {
        x = target_id.x;
        y = target_id.y - 20;
    }
    
    exit;
}
else
{
    image_alpha = 1;
    image_speed = 1;
}

if (!hit_done && image_index == hit_frame)
{
    var _x = x;
    
    if (instance_exists(target_id))
    {
        _x = target_id.x;
        
        with (target_id)
        {
            damage_amount = other.damage;
            damage_type = other.damage_type;
            event_user(0);
        }
        
        if (shape_bullet >= 1)
        {
            var _range = 165;
            var splash_ratio = 0.2;
            
            with (obj_enemy_parent)
            {
                if (hp > 0 && grid_row <= (other.row + 1) && grid_row >= (other.row - 1) && abs(x - _x) < _range && id != other.target_id && can_hit(other.target_type, target_type))
                {
                    damage_amount = other.damage * splash_ratio;
                    damage_type = other.damage_type;
                    event_user(0);
                }
            }
        }
    }
    
    hit_done = true;
    audio_play_sound(snd_cold_brew_machine, 0, 0);
}

if (image_index >= 8)
    instance_destroy();
