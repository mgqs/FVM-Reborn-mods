var _x = x;
var _y = y;

with (obj_enemy_parent)
{
    if (hp > 0 && abs(grid_row - other.grid_row) <= 2 && abs(grid_col - other.grid_col) <= 2)
    {
        damage_amount = other.atk;
        damage_type = "true";
        // 5×5 穿透打击属无类型伤害：放行钻地中的地精鼠（否则钻地期间完全免疫，表现为「打不到」）。
        if (variable_instance_exists(id, "ly_dig_hittable")) ly_dig_hittable = true;
        event_user(0);
        audio_play_sound(snd_hit1, 0, 0);
    }
}
