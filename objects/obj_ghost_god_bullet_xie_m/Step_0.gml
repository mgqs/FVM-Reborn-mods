if (global.is_paused)
{
    image_speed = 0;
    exit;
}

image_speed = 1;

if (burnt == 1)
    sprite_index = spr_fire_bullet;

x += abs(move_speed * 0.766);
y += (move_speed * 0.6428);

if (x > 2200 || y > 1200 || x < 0 || y < -200)
    instance_destroy();
