if (global.is_paused)
    exit;

life_timer--;
if (life_timer <= 0)
    instance_destroy();
