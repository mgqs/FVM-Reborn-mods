// obj_bbq_bullet Step 事件
// 直线飞行 + 全程穿透；命中后不消失，只在 hitted 里记一笔。
if (global.is_paused)
{
    exit;
}

// 过火（引擎碰撞触发，见 Collision_obj_brazier / fire_god / jinniu / ronghehuopen）：
//   一律换成通用「火弹」贴图（与玉米子弹等普通子弹同一口径）；
//   爆辣烤串（灼烧弹）同样要换，只是放大得更多、染成更红的火色，跟普通串串过火区分开。
if (burnt > 0)
{
    sprite_index = spr_fire_bullet;
    image_index = (life div 4) mod sprite_get_number(spr_fire_bullet);   // 火苗 4 帧自己轮播
    if (burn_shot)
    {
        image_xscale = 2.2;
        image_yscale = 2.2;
        image_blend = make_color_rgb(255, 150, 90);
    }
    else
    {
        image_xscale = 1.8;
        image_yscale = 1.8;
        image_blend = c_white;
    }
}

var _spd = (burnt > 0) ? burnt_speed : move_speed;
x += _spd * move_dir;
life++;

// 2026-10-31：飞到第 9 格右边边缘就消失（不飞出地图）；被反弹后往回飞出出膛点即销毁
if (move_dir > 0)
{
    if (x >= end_x || life > max_life)
    {
        instance_destroy();
        exit;
    }
}
else
{
    if (x <= start_x - 60 || life > max_life)
    {
        instance_destroy();
        exit;
    }
}

// 可被樱桃反弹布丁 / 水神反弹（照 obj_rig_bullet 的写法）：反向 + 加攻击力 + 转 180°
if (!bounced)
{
    with (obj_water_god)
    {
        if (other.bbox_right >= bbox_left && other.bbox_left <= bbox_right)
        {
            other.move_dir *= -1;
            other.damage += atk;
            other.image_angle += 180;
            other.bounced = true;
            break;
        }
    }
    if (!bounced)
    {
        with (obj_cherry_pudding)
        {
            if (other.bbox_right >= bbox_left && other.bbox_left <= bbox_right)
            {
                other.move_dir *= -1;
                other.damage += atk;
                other.image_angle += 180;
                other.bounced = true;
                break;
            }
        }
    }
}

if (variable_global_exists("enemy_by_type"))
{
    for (var _t = 0; _t < array_length(hittable_types); _t++)
    {
        var _key = hittable_types[_t];
        if (!variable_struct_exists(global.enemy_by_type, _key)) continue;
        var _list = global.enemy_by_type[$ _key];
        for (var _i = 0; _i < array_length(_list); _i++)
        {
            var _e = _list[_i];
            if (!instance_exists(_e) || _e.hp <= 0) continue;
            if (_e.grid_row != row) continue;
            if (ds_list_find_index(hitted, _e.id) != -1) continue;

            if (precise_bbox_collision(id, _e))
            {
                ds_list_add(hitted, _e.id);
                with (_e)
                {
                    damage_amount = other.damage;
                    damage_type = other.damage_type;
                    event_user(0);
                }
            }
        }
    }
}
