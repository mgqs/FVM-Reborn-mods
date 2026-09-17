var _x = x;
row = get_grid_position_from_world(_x, y).row;

if (instance_exists(target_enemy))
{
    _x = target_enemy.x;
    row = target_enemy.grid_row;
}

var _range = 165;

with (obj_enemy_parent)
{
    if (hp > 0 && abs(x - _x) < _range && grid_row <= (other.row + 1) && grid_row >= (other.row - 1) && id != other.target_enemy && can_hit(other.target_type, target_type))
    {
        damage_amount = other.damage * other.splash_ratio;
        damage_type = other.damage_type;
        event_user(0);
    }
}
