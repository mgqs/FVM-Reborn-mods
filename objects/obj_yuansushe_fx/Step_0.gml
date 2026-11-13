// obj_yuansushe_fx Step 事件：播完即销
if (global.is_paused)
{
    image_speed = 0;
    exit;
}
image_speed = 1;

fx_timer++;

if (fx_timer >= fx_life || image_index >= sprite_get_number(sprite_index))
    instance_destroy();
