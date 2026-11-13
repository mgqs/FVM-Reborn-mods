if (global.is_paused)
    exit;

event_inherited();
var current_flash_speed = flash_speed;

if (is_slowdown)
    current_flash_speed *= 2;

var has_enemy = false;
var target_enemy = -4;

target_enemy = combat_enemy_nearest_in_row(id, target_type);
has_enemy = (target_enemy != noone);

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

