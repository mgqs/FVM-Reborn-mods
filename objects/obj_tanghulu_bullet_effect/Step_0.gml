if (global.is_paused)
    exit;

timer++;
image_index = floor(timer / 5);

if (timer >= 35)
    instance_destroy();
