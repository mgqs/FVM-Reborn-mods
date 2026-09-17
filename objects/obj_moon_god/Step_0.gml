if (global.is_paused)
    exit;

event_inherited();
var current_flash_speed = flash_speed;

if (is_slowdown)
    current_flash_speed *= 2;

final_atk = atk;
var has_enemy = false;

if (instance_exists(obj_enemy_parent))
{
    with (obj_enemy_parent)
    {
        if (can_target_on(other.target_type, target_type))
            has_enemy = true;
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
    
    if (attack_timer == (cycle - (8 * flash_speed)))
    {
        if (shape == 3)
        {
            var num = instance_number(obj_moon_god);
            final_atk = atk * min(0.95 + (num * 0.05), 1.45);
        }
        
        event_user(3);
    }
    
    if (attack_timer == (cycle - (7 * flash_speed)))
        event_user(1);
    
    if (attack_timer == (cycle - (6 * flash_speed)))
        event_user(1);
    
    if (attack_timer == (cycle - (5 * flash_speed)))
        event_user(1);
    
    if (attack_timer == (cycle - (4 * flash_speed)))
        event_user(1);
    
    if (attack_timer == (cycle - (3 * flash_speed)))
        event_user(1);
    
    if (attack_timer == (cycle - (2 * flash_speed)))
        event_user(1);
    
    if (attack_timer == (cycle - (1 * flash_speed)) && (shape == 1 || shape == 3))
        event_user(1);
}
else
{
    attack_timer = 0;
    state = 0;
}

