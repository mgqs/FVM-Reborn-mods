var _x = x;
var _y = y;
var _range = 250;
var _damage = atk;
var _damage_type = damage_type;

with (obj_enemy_parent)
{
    if (point_distance(x, y, _x, _y) < _range && grid_row >= (other.grid_row - 1) && grid_row <= (other.grid_row + 1))
    {
        damage_amount = _damage;
        damage_type = other.damage_type;
        event_user(0);
        audio_play_sound(snd_hit1, 0, 0);
    }
}
