if (global.is_paused)
{
    image_speed = 0;
    exit;
}

image_speed = 3;
timer++;

if (timer >= explode_timer)
    instance_destroy();
