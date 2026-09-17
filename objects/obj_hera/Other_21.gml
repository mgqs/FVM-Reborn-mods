var _x = x;
var _y = y;

with (obj_enemy_parent)
{
    if (hp > 0 && abs(grid_row - other.grid_row) <= 2 && abs(grid_col - other.grid_col) <= 2)
    {
        hp -= other.bleed_damage;
        event_user(0);
    }
}