var _x = x;
var _y = y;
var _range = 2;

if (shape == 3)
    _range = 3;

with (obj_enemy_parent)
{
    if (hp > 0 && abs(grid_row - other.grid_row) <= 2 && abs(grid_col - other.grid_col) <= _range)
    {
        if (ice_timer <= 600 && other.shape >= 1)
            ice_timer = 600;
        
        hp -= other.atk;
        event_user(0);
        audio_play_sound(snd_hit1, 0, 0);
    }
}
