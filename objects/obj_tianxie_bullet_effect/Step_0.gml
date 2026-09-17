if (global.is_paused)
    exit;

timer++;
image_index = floor(timer);

if (timer >= 19)
    instance_destroy();
