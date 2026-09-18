if (global.is_paused)
{
    image_speed = 0;
    exit;
}

image_speed = 1;

if (image_index >= image_number - 1)
    instance_destroy();
