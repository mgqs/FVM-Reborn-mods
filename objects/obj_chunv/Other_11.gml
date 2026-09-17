var _x = x;
var _y = y;
var _row = 1;
var _m = 1.3;

if (shape == 0)
    _m = 1;

if (shape == 2)
    _row = 2;

with (obj_enemy_parent)
{
    if (hp > 0 && abs(grid_row - other.grid_row) <= _row && abs(grid_col - other.grid_col) <= _row)
    {
        hp -= (_m * other.bleed_damage);
        event_user(0);
    }
}
