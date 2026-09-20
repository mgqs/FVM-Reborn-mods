if (global.is_paused)
{
    image_speed = 0;
    exit;
}

image_speed = 1;

if (bullet_shape == 1)
    sprite_index = spr_tanghulu_bullet_1;
else if (bullet_shape == 2)
    sprite_index = spr_tanghulu_bullet_2;
else
    sprite_index = spr_tanghulu_bullet;

image_alpha = 1;
timer++;

if (instance_exists(target_enemy) && target_enemy.hp > 0)
{
    var target_x = target_enemy.x;
    var target_y = target_enemy.y - 75;
    var dir = point_direction(x, y, target_x, target_y);
    x += lengthdir_x(move_speed, dir);
    y += lengthdir_y(move_speed, dir);
    var new_air_target = -4;

    with (obj_enemy_parent)
    {
        if (hp > 0 && can_hit(other.target_type, target_type))
        {
            if (new_air_target == -4 || x < new_air_target.x || (x == new_air_target.x && hp > new_air_target.hp))
                new_air_target = id;
        }
    }

    if (new_air_target != -4)
        target_enemy = new_air_target;
}
else
{
    var air_enemy = -4;

    with (obj_enemy_parent)
    {
        if (hp > 0 && can_hit(other.target_type, target_type))
        {
            if (air_enemy == -4 || x < air_enemy.x || (x == air_enemy.x && hp > air_enemy.hp))
                air_enemy = id;
        }
    }

    if (air_enemy != -4)
    {
        target_enemy = air_enemy;
    }
    else
    {
        var dir = point_direction(xstart, ystart, x, y);
        x += lengthdir_x(move_speed, dir);
        y += lengthdir_y(move_speed, dir);
    }
}

if (x > 2200 || y > 1200 || x < -200 || y < -200)
    instance_destroy();
