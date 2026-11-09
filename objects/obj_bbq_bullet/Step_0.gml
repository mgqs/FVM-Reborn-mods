// obj_bbq_bullet Step 事件
// 直线飞行 + 全程穿透；命中后不消失，只在 hitted 里记一笔。
if (global.is_paused)
{
    exit;
}

// 过火（引擎碰撞触发，见 Collision_obj_brazier / fire_god / jinniu / ronghehuopen）：
//   一律换成通用「火弹」贴图（与玉米子弹等普通子弹同一口径）。
//   2026-11-10 用户口径：**爆辣烤串不再单独放大/染色，统一掉**（原来 2.2 倍 + 偏红火色会盖住融盆二转的冰弹外观）。
//   融盆 2 转会把子弹改成冰弹（贴图 + 1.4 倍 + brazier_list 里插哨兵 -9999），这里必须让路，否则每帧被改回火球。
var _is_ice_bullet = (variable_instance_exists(id, "brazier_list")
                   && ds_list_find_index(brazier_list, -9999) != -1);
if (burnt > 0 && !_is_ice_bullet)
{
    sprite_index = spr_fire_bullet;
    image_index = (life div 4) mod sprite_get_number(spr_fire_bullet);   // 火苗 4 帧自己轮播
    image_xscale = 1.8;
    image_yscale = 1.8;
    image_blend = c_white;
}

var _spd = (burnt > 0) ? burnt_speed : move_speed;
x += _spd * move_dir;
life++;

// 2026-10-31：飞到第 9 格右边边缘就消失（不飞出地图）
// 2026-11-02：右端放到第 11 格右沿（出图 2 格）；向左飞（身后目标 / 被反弹）用 end_x_left，
//   两个端点都由 obj_bbq 传，反弹后照样能扫回整行而不是就地消失。
if (life > max_life)
{
    instance_destroy();
    exit;
}
if (move_dir > 0)
{
    if (x >= end_x)
    {
        instance_destroy();
        exit;
    }
}
else
{
    if (x <= end_x_left)
    {
        instance_destroy();
        exit;
    }
}

// 反弹交给引擎碰撞事件（Collision_obj_cherry_pudding / Collision_obj_water_god，同 rig / 玉米那批子弹）
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
