if (global.is_paused)
{
    image_speed = 0;
    speed = 0;
    exit;
}

image_speed = 2;
speed = 4.8;
t += (speed * dir);

if (t >= 950)
{
    t = 950;
    dir = -1;
}

if (t <= 0 && dir == -1)
{
    disabled = true;
    instance_destroy();
    exit;
}

if (t <= 40)
    image_alpha = 0;
else
    image_alpha = 1;

var px = t;
var py = -14 * sqrt(px) * sin(0.006613879270715354 * px);

if (dir == -1)
    py = -py;

x = start_x + px;
y = start_y + py;
