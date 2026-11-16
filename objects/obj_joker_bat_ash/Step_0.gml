if (global.is_paused)
    exit;

bat_timer++;
var _f = floor(bat_timer / bat_step);

if (_f >= sprite_get_number(sprite_index))
{
    instance_destroy();
    exit;
}

image_index = _f;
