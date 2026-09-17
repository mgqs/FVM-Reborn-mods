if (global.is_paused)
    exit;

event_inherited();
var current_flash_speed = flash_speed;

if (is_slowdown)
    current_flash_speed *= 2;

if (transform_timer > 4)
    transform_timer--;
else
    instance_destroy();

if (transform_timer <= 15 && !henshin)
{
    transform_into_target();
    transform_into_target();
    
    if (shape >= 2)
        transform_into_target();
    
    henshin = true;
}
else if (shape >= 1 && transform_timer <= 55 && !exploded)
{
    event_user(1);
    exploded = true;
}
