if (global.is_paused)
    exit;

if (cooldown_timer > 0)
    cooldown_timer--;
else
    cooldown_timer = cooldown;
