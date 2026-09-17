if (global.is_paused)
    exit;

timer++;
image_index = floor(timer / 5) + (18 * state);

if (timer >= 89)
    instance_destroy();
