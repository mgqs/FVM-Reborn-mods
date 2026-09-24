if (global.is_paused)
{
    image_speed = 0;
    exit;
}

image_speed = 1;
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
        if (hp > 0 && can_hit(other.target_type, target_type) && target_type == "air")
        {
            if (new_air_target == -4 || x < new_air_target.x)
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
        if (hp > 0 && can_hit(other.target_type, target_type) && target_type == "air")
        {
            if (air_enemy == -4 || x < air_enemy.x)
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

// 追踪子弹碰撞检测
if (target_enemy != -4 && instance_exists(target_enemy))
{
    var _e = target_enemy;
    if (_e.hp > 0
    && precise_bbox_collision(id, _e))
    {
        var _hit_id = _e.id;
        with (_e)
        {
            audio_play_sound(hit_sound, 0, 0);

            if (hp > other.damage)
            {
                hp -= other.damage;
                event_user(0);
            }
            else
            {
                if (special_ash)
                {
                    var inst = instance_create_depth(x, y - 20, depth, obj_mouse_ash_death);
                    inst.special_ash = true;
                    inst.sprite_index = sprite_index;
                    inst.image_index = image_index;
                }
                else
                {
                    instance_create_depth(x, y - 20, depth, obj_mouse_ash_death);
                }
                instance_destroy();
            }
        }

        var stun_chance = (bullet_shape == 0) ? 15 : 30;

        if (random(100) < stun_chance)
        {
            if (instance_exists(_e) && _e.stun_timer < 240)
                _e.stun_timer = 240;
        }

        instance_create_depth(x, y, depth, obj_power_god_bullet_effect);
        instance_destroy();
    }
}

if (x > 2200 || y > 1200 || x < -200 || y < -200)
    instance_destroy();
