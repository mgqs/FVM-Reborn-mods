if (global.is_paused)
{
    image_speed = 0;
    exit;
}

image_speed = 1;
timer++;

if (timer == 10)
{
    audio_play_sound(snd_zeus, 0, 0);
}
else if (timer == 30)
{
    var _x = x;
    var _y = y;
    var _damage = atk;
    var _damage_type = damage_type;
    
    with (obj_enemy_parent)
    {
        if (hp > 0 && abs(grid_row - other.grid_row) <= other._r && abs(x - other.x) <= other._range)
        {
            if (hp > _damage)
            {
                hp -= _damage;
                event_user(0);
            }
            else
            {
                instance_create_depth(x, y - 20, depth, obj_mouse_ash_death);
                instance_destroy();
            }
        }
    }
}
