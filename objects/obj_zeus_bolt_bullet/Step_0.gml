if (global.is_paused)
{
    image_speed = 0;
    exit;
}

image_speed = 1.5;
timer++;

if (instance_exists(target_enemy) && target_enemy.hp > 0)
{
    var target_x = target_enemy.x;
    var target_y = target_enemy.y - 75;
    var dir = point_direction(x, y, target_x, target_y);
    x += lengthdir_x(move_speed, dir);
    y += lengthdir_y(move_speed, dir);
    var new_target = -4;
    var closest_left_enemy = -4;
    var air_enemy = -4;
    var min_x = room_width;
    var max_hp = 0;
    var right_range = 150;
    
    with (obj_enemy_parent)
    {
        if (hp > 0 && can_hit(other.target_type, target_type))
        {
            if (instance_exists(other.banding_card_obj))
            {
                if (x >= other.banding_card_obj.x && x <= (other.banding_card_obj.x + right_range) && grid_row == other.row)
                {
                    if (new_target == -4 || hp > new_target.hp)
                        new_target = id;
                }
            }
            
            if (target_type == "air")
            {
                if (air_enemy != -4 && instance_exists(air_enemy))
                {
                    if (x < air_enemy.x)
                        air_enemy = id;
                }
                else
                {
                    air_enemy = id;
                }
            }
            
            if (x < other.target_enemy.x)
            {
                if (closest_left_enemy == -4 || x < min_x || (x == min_x && hp > max_hp))
                {
                    min_x = x;
                    max_hp = hp;
                    closest_left_enemy = id;
                }
            }
        }
    }
    
    if (new_target != -4)
        target_enemy = new_target;
    else if (air_enemy != -4)
        target_enemy = air_enemy;
    else if (closest_left_enemy != -4)
        target_enemy = closest_left_enemy;
}
else
{
    var new_target = -4;
    var closest_left_enemy = -4;
    var air_enemy = -4;
    var min_x = room_width;
    var max_hp = 0;
    var right_range = 80;
    
    with (obj_enemy_parent)
    {
        if (hp > 0 && can_hit(other.target_type, target_type))
        {
            if (instance_exists(other.banding_card_obj))
            {
                if (x >= other.banding_card_obj.x && x <= (other.banding_card_obj.x + right_range) && grid_row == other.row)
                {
                    if (new_target == -4 || hp > new_target.hp)
                        new_target = id;
                }
            }
            
            if (target_type == "air")
            {
                if (air_enemy != -4 && instance_exists(air_enemy))
                {
                    if (x < air_enemy.x)
                        air_enemy = id;
                }
                else
                {
                    air_enemy = id;
                }
            }
            
            if (x < min_x || (x == min_x && hp > max_hp))
            {
                min_x = x;
                max_hp = hp;
                closest_left_enemy = id;
            }
        }
    }
    
    if (new_target != -4)
    {
        target_enemy = new_target;
    }
    else if (air_enemy != -4)
    {
        target_enemy = air_enemy;
    }
    else if (closest_left_enemy != -4)
    {
        target_enemy = closest_left_enemy;
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
