if (global.is_paused)
    exit;

event_inherited();

if (is_frozen)
    exit;

var current_flash_speed = flash_speed;

if (is_slowdown)
    current_flash_speed *= 2;

var has_enemy = false;

with (obj_enemy_parent)
{
    if (grid_row >= (other.grid_row - 1) && grid_row <= (other.grid_row + 1) && grid_col >= other.grid_col && grid_col <= (global.grid_cols + 1) && can_target_on(other.target_type, target_type))
    {
        has_enemy = true;
        break;
    }
}

if (has_enemy)
{
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
        attack_timer = 0;
        state = 0;
    }
    
    if (attack_timer == (cycle - (5 * flash_speed)))
    {
        fire_mid = true;
        fire_up = true;
        fire_down = true;
        event_user(1);
    }
    
    if (attack_timer == (cycle - (3 * flash_speed)))
    {
        fire_mid = true;
        fire_up = shape == 2;
        fire_down = shape == 2;
        event_user(1);
    }
}
else
{
    attack_timer = 0;
    state = 0;
}

