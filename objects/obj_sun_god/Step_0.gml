if (global.is_paused)
    exit;

event_inherited();
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
        state = CARD_STATE.ATTACK;
    }

    if (attack_timer >= (first_produce_delay - 40))
    {
        event_user(1);

        if (shape == 3)
            event_user(1);

        first_produce = 1;
        attack_timer = -40;
        state = CARD_STATE.IDLE;
    }
}
else
{
    if (attack_timer <= (cycle - (attack_anim * current_flash_speed)))
    {
        attack_timer++;
    }
    else if (attack_timer <= cycle)
    {
        attack_timer++;
        state = CARD_STATE.ATTACK;
    }

    if (attack_timer >= (cycle - 40))
    {
        event_user(1);
        attack_timer = -40;
        state = CARD_STATE.IDLE;
    }
}