event_inherited();

if (global.is_paused) exit;
if (t > life + 4) exit;
if (drunk_time <= 0) exit;

with (obj_enemy_parent)
{
    if (hp <= 0) continue;
    if (grid_col != other.grid_col || grid_row != other.grid_row) continue;
    if (is_boss) continue;

    drunk_timer = other.drunk_time;
    drunk_mult  = other.drunk_mult;
    if (!variable_instance_exists(id, "drunk_fx") || !instance_exists(drunk_fx))
    {
        drunk_fx = instance_create_depth(x, y, depth - 2, obj_guihuajiu_drunk);
        drunk_fx.target = id;
    }
}
