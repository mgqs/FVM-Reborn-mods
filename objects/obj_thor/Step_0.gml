if (global.is_paused)
    exit;

event_inherited();
var current_flash_speed = flash_speed;

if (is_slowdown)
    current_flash_speed *= 2;

var has_enemy = false;
var target_enemy = -4;
var min_distance = 10000;

with (obj_enemy_parent)
{
    if (grid_row == other.grid_row && grid_col >= other.grid_col && grid_col <= (global.grid_cols + 1) && can_target_on(other.target_type, target_type))
    {
        var distance = grid_col - other.grid_col;
        
        if (distance < min_distance)
        {
            min_distance = distance;
            target_enemy = id;
            has_enemy = true;
        }
    }
}

if (has_enemy)
    target_instance = target_enemy;
else
    target_instance = -4;

if (has_enemy)
{
    if (attack_timer <= (cycle - (attack_anim * current_flash_speed)))
    {
        attack_timer++;
    }
    else if (attack_timer == (cycle - 30))
    {
        event_user(1);
        super_bullet++;
        attack_timer++;
    }
    else if (attack_timer <= cycle)
    {
        if (attack_timer == (cycle - 20))
            event_user(1);
        
        if (attack_timer == (cycle - 10) && shape >= 1)
            event_user(1);
        
        if (attack_timer == (cycle - 40) && shape == 2 && super_bullet >= 3)
        {
            event_user(3);
            super_bullet = 1;
        }
        
        if (attack_timer == (cycle - 40) && shape == 3)
            event_user(3);
        
        attack_timer++;
        state = 1;
    }
    else
    {
        attack_timer = 0;
        state = 0;
    }
}
else
{
    attack_timer = 0;
    state = 0;
}

