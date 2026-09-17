if (can_destroy)
{
    if (timer > 0)
        timer--;
    else
        instance_destroy();
}

if (global.is_paused)
    image_speed = 0;
else if (!can_destroy)
    image_speed = 1;
