var _x = x;
var _y = y;
var _row_range = 1;

if (instance_exists(hitted_enemy))
{
    _x = hitted_enemy.x;
    _y = hitted_enemy.y;
}

var _range = 200;
var splash_ratio = 0.4;

if (shape == 2)
    splash_ratio = 0.45;

if (shape == 3)
    splash_ratio = 1;

with (obj_enemy_parent)
{
    if (hp > 0 && point_distance(x, y, _x, _y) < _range && grid_row <= (other.row + _row_range) && grid_row >= (other.row - _row_range) && id != other.hitted_enemy)
    {
        damage_amount = other.damage * splash_ratio;
        damage_type = other.damage_type;
        
        if (ice_timer < 600)
            ice_timer = 600;
        
        event_user(0);
    }
}

audio_play_sound(snd_egg_bullet, 0, 0);
