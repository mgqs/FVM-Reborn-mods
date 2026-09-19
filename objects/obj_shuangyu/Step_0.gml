if (global.is_paused)
    exit;

var current_flash_speed = flash_speed;

if (is_slowdown)
    current_flash_speed *= 2;

event_inherited();
var has_enemy = false;
target_instance = -4;

if (instance_exists(obj_enemy_parent))
{
    with (obj_enemy_parent)
    {
        if (grid_row == other.grid_row && grid_col >= other.grid_col && grid_col <= (global.grid_cols + 1) && hp > 0 && can_target_on(other.target_type, target_type))
        {
            has_enemy = true;
            break;
        }
    }
}

if (has_enemy)
{
    var min_x = 9999;
    with (obj_enemy_parent)
    {
        if (grid_row == other.grid_row && grid_col >= other.grid_col && grid_col <= (global.grid_cols + 1) && hp > 0 && x < min_x && can_target_on(other.target_type, target_type))
        {
            min_x = x;
            other.target_instance = id;
        }
    }

    if (attack_timer <= (cycle - (attack_anim * current_flash_speed)))
    {
        attack_timer++;
    }
    else if (attack_timer <= cycle)
    {
        attack_timer++;
        state = 1;
    }
    else
    {
        event_user(1);
        attack_timer = 0;
        state = 0;
    }
}
else
{
    if (attack_timer > 0)
        attack_timer = 0;
    state = 0;
}
