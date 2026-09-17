if (global.is_paused)
{
    image_speed = 0;
    exit;
}

image_speed = 1;
x += move_speed;

if (burnt == 1)
    sprite_index = spr_fire_bullet;

if (x > 2200 || y > 1200 || x < 0 || y < 0)
    instance_destroy();
