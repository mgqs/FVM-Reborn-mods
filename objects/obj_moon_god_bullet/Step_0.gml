if (global.is_paused)
    exit;

timer++;

// 追踪子弹碰撞检测
if (target_enemy != -4 && instance_exists(target_enemy))
{
    var _e = target_enemy;
    if (_e.hp > 0
        && bbox_right >= _e.bbox_left && bbox_left <= _e.bbox_right
        && bbox_bottom >= _e.bbox_top && bbox_top <= _e.bbox_bottom)
    {
        with (_e)
        {
            audio_play_sound(hit_sound, 0, 0);
            damage_amount = other.damage;
            damage_type = other.damage_type;
            event_user(0);
        }
        instance_create_depth(x, y, depth, obj_takoyaki_bullet_effect);
        instance_destroy();
    }
}

if (x > 2200 || y > 1200 || x < -200 || y < -200)
{
    instance_destroy();
    exit;
}

image_angle = -timer * 6;
var needs_retarget = false;

if (!instance_exists(target_enemy) || target_enemy.hp <= 0)
{
    target_enemy = -4;
    needs_retarget = true;
}

scan_timer++;

if (scan_timer >= 10)
{
    needs_retarget = true;
    scan_timer = 0;
}

if (needs_retarget)
{
    var _my_type = target_type;
    var _my_row = row;
    var _plant_exists = instance_exists(banding_card_obj);
    var _plant_x = _plant_exists ? banding_card_obj.x : 0;
    var _right_range = 150;
    var _current_target_x = (target_enemy != -4) ? target_enemy.x : room_width;
    var best_close = -4;
    var best_close_hp = -1;
    var best_air = -4;
    var min_air_x = room_width;
    var best_left = -4;
    var min_left_x = room_width;
    var max_left_hp = -1;
    
    with (obj_enemy_parent)
    {
        if (hp > 0 && can_hit(_my_type, target_type))
        {
            if (_plant_exists && grid_row == _my_row && x >= _plant_x && x <= (_plant_x + _right_range))
            {
                if (best_close == -4 || hp > best_close_hp)
                {
                    best_close = id;
                    best_close_hp = hp;
                }
            }
            
            if (target_type == "air")
            {
                if (x < min_air_x)
                {
                    min_air_x = x;
                    best_air = id;
                }
            }
            
            if (x < _current_target_x)
            {
                if (x < min_left_x || (x == min_left_x && hp > max_left_hp))
                {
                    min_left_x = x;
                    max_left_hp = hp;
                    best_left = id;
                }
            }
        }
    }
    
    if (best_close != -4)
        target_enemy = best_close;
    else if (best_air != -4)
        target_enemy = best_air;
    else if (best_left != -4)
        target_enemy = best_left;
}

if (target_enemy != -4)
{
    fly_dir = point_direction(x, y, target_enemy.x, target_enemy.y - 75);
}
else
{
}

x += lengthdir_x(move_speed, fly_dir);
y += lengthdir_y(move_speed, fly_dir);
