if (global.is_paused)
    exit;

if (bullet_hit)
{
    hit_anim_timer++;
    image_index = 4 + floor(hit_anim_timer / 5);

    if (hit_anim_timer >= 15)
    {
        bullet_hit = false;
        hit_anim_timer = 0;
        anim_timer = 0;
    }
}
else
{
    if (anim_timer < 19)
        anim_timer++;
    else
        anim_timer = 0;

    image_index = floor(anim_timer / 5);
}

x += move_speed_x;
y += move_speed_y;

// 类型过滤碰撞检测：仅遍历可命中的敌人类型，斜射子弹不受行限制
if (!bullet_hit && variable_global_exists("enemy_by_type"))
{
    for (var _t = 0; _t < array_length(hittable_types); _t++)
    {
        var _key = hittable_types[_t];
        if (!variable_struct_exists(global.enemy_by_type, _key)) continue;
        var _list = global.enemy_by_type[$ _key];
        for (var _i = 0; _i < array_length(_list); _i++)
        {
            var _e = _list[_i];
            if (!instance_exists(_e)) continue;
            with (_e)
            {
                if (hp > 0
                    && ds_list_find_index(other.hitted_enemy, id) == -1
                    && other.bbox_right >= bbox_left && other.bbox_left <= bbox_right
                    && other.bbox_bottom >= bbox_top && other.bbox_top <= bbox_bottom)
                {
                    audio_play_sound(hit_sound, 0, 0);
                    damage_amount = other.damage;
                    damage_type = other.damage_type;
                    event_user(0);

                    ds_list_add(other.hitted_enemy, id);
                    other.bullet_hit = true;
                }
            }
        }
    }
}

if (x > 2200 || y > 1200 || x < 0 || y < 0)
    instance_destroy();
