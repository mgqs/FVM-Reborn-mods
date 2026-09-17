if (global.is_paused)
    exit;

event_inherited();

if (is_frozen)
    exit;

var current_flash_speed = flash_speed;

if (is_slowdown)
    current_flash_speed *= 2;

if (first_produce == 0)
{
    if (attack_timer <= first_produce_delay)
    {
        attack_timer++;
    }
    else if (attack_timer <= (first_produce_delay + (attack_anim * current_flash_speed)))
    {
        attack_timer++;
        state = 1;
    }
    else
    {
        event_user(1);
        attack_timer = 0;
        state = 0;
        first_produce = 1;
    }
}
else if (attack_timer <= (cycle - (attack_anim * current_flash_speed)))
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
    event_user(1);
    attack_timer = 0;
    state = 0;
}

