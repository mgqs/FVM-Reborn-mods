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
        
        damage_amount = other.atk;
        damage_type = "true";
        // 喷壶类可命中钻地中的地精鼠
        if (variable_instance_exists(id, "ly_dig_hittable")) ly_dig_hittable = true;
        event_user(0);
        audio_play_sound(snd_hit1, 0, 0);
    }
}