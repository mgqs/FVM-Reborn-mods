if (global.is_paused)
{
    image_speed = 0;
    exit;
}

image_speed = 1;
x += lengthdir_x(move_speed, direction);
y += lengthdir_y(move_speed, direction);
image_angle = direction;

if (x > 2500 || x < -200 || y > 1500 || y < -200)
    instance_destroy();
