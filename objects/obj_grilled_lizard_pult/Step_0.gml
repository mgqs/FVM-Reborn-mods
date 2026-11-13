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
    state = 0;
    exit;
}

var has_enemy = false;
var target_enemy = -4;

if (!attacking)
{
    
    target_enemy = combat_enemy_nearest_in_row(id, target_type);
    has_enemy = (target_enemy != noone);
}

if (has_enemy)
{
    target_instance = target_enemy;
    attacking = true;
}

if (attacking)
{
    state = 1;
    attack_timer++;
    
    if (attack_timer == ((attack_anim - 4) * current_flash_speed))
        event_user(1);
    
    if (attack_timer == ((attack_anim - 2) * current_flash_speed) && shape == 2)
        event_user(1);
    
    if (attack_timer >= (attack_anim * current_flash_speed))
    {
        attacking = false;
        cooldown_timer = cycle - attack_timer;
        attack_timer = 0;
        target_instance = -4;
    }
}

