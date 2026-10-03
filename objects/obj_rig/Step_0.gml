if (global.is_paused)
    exit;

event_inherited();

if (is_frozen || state == 4)
    exit;

var current_flash_speed = flash_speed;

if (is_slowdown)
    current_flash_speed *= 2;

if (cooldown_timer > 0)
{
    cooldown_timer--;
    exit;
}

if (!attacking)
{
    with (obj_enemy_parent)
    {
        if (grid_col > other.grid_col && can_target_on(other.target_type, target_type) && hp > 0)
        {
            other.attacking = true;
            break;
        }
    }
}

if (attacking)
{
    state = 1;
    attack_timer++;
    
    if (attack_timer == ((attack_anim - 10) * current_flash_speed))
        event_user(1);
    
    if (attack_timer >= (attack_anim * current_flash_speed) || attack_timer >= cycle)
    {
        attacking = false;
        cooldown_timer = cycle - attack_timer;
        attack_timer = 0;
        state = 0;
    }
}

