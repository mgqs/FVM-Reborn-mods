if (global.is_paused)
    exit;

var current_flash_speed = flash_speed;
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
    else if (attack_timer == (cycle - 5))
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

