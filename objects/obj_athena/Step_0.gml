if (global.is_paused)
    exit;

var current_flash_speed = flash_speed;

if (is_slowdown)
    current_flash_speed *= 2;

event_inherited();
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
    else if (attack_timer == (cycle - 55))
    {
        event_user(1);
        attack_timer++;
    }
    else if (attack_timer == (cycle - 45) && shape == 2)
    {
        event_user(1);
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
}

