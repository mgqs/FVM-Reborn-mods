// obj_fashishe_bullet Step 事件
// 蛇形飞行 + 全程穿透；带毒的那一发（每 3 发一颗）飞到行末时，在行末 1/3 格铺毒雾。
// 飞到「地图右沿 +2 格」（出图 2 格，同 bbq）→ 播贴图里的消散帧（第 5 帧起）再销毁。
if (global.is_paused) exit;

// 消散段：播一遍就销毁（0/1 转 5~6 帧，2 转 5~8 帧）
if (fading)
{
    fade_t++;
    image_index = fade_first + (fade_t div 4);
    if (image_index > fade_last) instance_destroy();
    exit;
}

// 过火外观（同 bbq 子弹：一律换成通用火弹贴图）
if (burnt > 0)
{
    sprite_index = spr_fire_bullet;
    image_index  = (life div 4) mod sprite_get_number(spr_fire_bullet);
    image_xscale = 1.6;
    image_yscale = 1.6;
}

x += move_speed * move_dir;
life++;

// 普通状态按帧轮播：1~4 帧是飞行，5 帧起是消散（不在这里播）
if (burnt == 0) image_index = (life div 4) mod 4;

// 蛇形轨迹：只在向右飞时摆，被反弹后走直线
if (move_dir > 0)
    y = base_y + sin(life * wave_speed + phase) * wave_amp;
else
    y = lerp(y, base_y, 0.2);

// ── 出界 ──
if ((move_dir > 0 && x >= end_x) || (move_dir < 0 && x <= end_x_left))
{
    // 过火后贴图是通用火球，没有消散帧 → 直接销毁
    if (burnt > 0)
    {
        instance_destroy();
        exit;
    }

    // 播消散帧（0/1 转 7 帧 → 第 5、6 帧；2 转 10 帧 → 第 5~8 帧）
    fading     = true;
    fade_t     = 0;
    fade_first = 4;
    fade_last  = (sprite_get_number(sprite_index) >= 10) ? 7 : 5;
    image_index = fade_first;
    exit;
}

if (life > max_life)
{
    instance_destroy();
    exit;
}

// 穿透命中：沿途每只老鼠只吃一次
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
                    damage_type   = other.damage_type;
                    event_user(0);
                }
            }
        }
    }
}
