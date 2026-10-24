if (global.is_paused)
{
    image_speed = 0;
    exit;
}

image_speed = 1;

if (point_distance(x, y, target_x, target_y) <= move_speed)
{
    event_user(7);
}
else
{
    var dir = point_direction(x, y, target_x, target_y);
    x += lengthdir_x(move_speed, dir);
    y += lengthdir_y(move_speed, dir);
}
