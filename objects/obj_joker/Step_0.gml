if (global.is_paused)
    exit;

event_inherited();

if (is_frozen || state == 4)
    exit;

var current_flash_speed = flash_speed;

if (is_slowdown)
    current_flash_speed *= 2;

if (cooldown > 0)
{
    cooldown--;
    exit;
}

if (!attacking)
{
    with (obj_enemy_parent)
    {
        if (target_type == "air" && grid_row == other.grid_row && hp > 0)
        {
            other.target_t = "air_only";
            other.attacking = true;
            break;
        }
        
        if (can_target_on(other.target_type, target_type) && grid_row == other.grid_row && hp > 0)
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
    
    if (attack_timer == ((attack_anim * flash_speed) - 65))
        event_user(1);
    
    if (attack_timer == ((attack_anim * flash_speed) - 50))
        event_user(1);
    
    if (attack_timer == ((attack_anim * flash_speed) - 35))
        event_user(1);
    
    if (attack_timer == ((attack_anim * flash_speed) - 20) && shape >= 2)
        event_user(1);
    
    if (attack_timer >= (attack_anim * flash_speed))
    {
        attacking = false;
        cooldown = cycle - attack_timer;
        attack_timer = 0;
        state = 0;
        target_t = "rotate";
    }
}

