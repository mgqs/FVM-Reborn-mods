if (global.is_paused)
    exit;

event_inherited();

if (is_frozen || state == 4)
    exit;

var current_flash_speed = flash_speed;

if (is_slowdown)
    current_flash_speed *= 2;

var has_enemy = false;

if (shape < 2)
{
    with (obj_enemy_parent)
    {
        if (grid_row == other.grid_row && grid_col >= other.grid_col && grid_col <= (other.grid_col + 4) && can_target_on(other.target_type, target_type))
        {
            has_enemy = true;
            break;
        }
    }
}
else
{
    with (obj_enemy_parent)
    {
        if (grid_row == other.grid_row && grid_col >= other.grid_col && grid_col <= (other.grid_col + 5) && can_target_on(other.target_type, target_type))
        {
            has_enemy = true;
            break;
        }
    }
}

var wait_time = cycle - (attack_anim * current_flash_speed);

if (wait_time < 0)
    wait_time = 0;

var is_executing_attack = attack_timer > wait_time && attack_timer < (wait_time + (attack_anim * current_flash_speed));

if (has_enemy || is_executing_attack)
{
    if (attack_timer < wait_time)
    {
        attack_timer++;
        state = 0;
        damage_timer = 0;
    }
    else if (attack_timer < (wait_time + (attack_anim * current_flash_speed)))
    {
        attack_timer++;
        state = 1;
        
        if (image_index >= (idle_anim + 1 + 7) && image_index <= (idle_anim + 1 + attack_anim))
            event_user(1);
        else
            damage_timer = 0;
    }
    else
    {
        attack_timer = 0;
        state = 0;
        damage_timer = 0;
    }
}
else
{
    if (attack_timer >= (wait_time + (attack_anim * current_flash_speed)))
        attack_timer = 0;
    else if (attack_timer < wait_time)
        attack_timer++;
    
    state = 0;
    damage_timer = 0;
}

