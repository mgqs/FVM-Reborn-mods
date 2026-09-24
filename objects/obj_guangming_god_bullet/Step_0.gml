if (global.is_paused)
    exit;

anim_frame += anim_speed;
image_index = floor(min(anim_frame, image_number - 1));

if (anim_frame >= image_number)
{
    instance_destroy();
    exit;
}
