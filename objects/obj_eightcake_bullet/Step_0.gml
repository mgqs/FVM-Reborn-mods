// obj_eightcake_bullet Step 事件
// 抛物线点到点飞行；**飞行途中碰到老鼠就命中（单体）**，打不到才落到目标格再做一次单体结算。
// 路线口径照其他投手（obj_eggboilerpult_bullet）：起点在勺子上、弧线飞出去、碰到谁打谁。
if (global.is_paused) exit;
if (landed) exit;

t++;

// 飞行段自己推帧循环 0~fly_end（精灵第 17 帧是空帧，按 image_speed 递增会「飞到一半消失」）
image_index = floor(t * fly_anim_speed) mod (fly_end + 1);

var _p = min(1, t / T);
x = lerp(sx, tx, _p);
y = lerp(sy, ty, _p) - arc * 4 * _p * (1 - _p);

// ===== 飞行中命中：相机判定，碰到第一只就打（单体，同其他投手） =====
hit_tick++;
if (hit_tick >= global.bullet_hit_interval && variable_global_exists("enemy_by_type"))
{
    hit_tick = 0;
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

            if (precise_bbox_collision(id, _e))
            {
                landed = true;
                with (_e)
                {
                    damage_amount = other.damage;
                    damage_type = other.damage_type;
                    event_user(0);
                }
                instance_destroy();
                exit;
            }
        }
    }
}

if (t < T) exit;

// ===== 落地：没撞到人就打落点上最近的一只（单体） =====
landed = true;

if (variable_global_exists("enemy_by_type"))
{
    var _best = noone;
    var _best_d = 0;
    for (var _t2 = 0; _t2 < array_length(hittable_types); _t2++)
    {
        var _key2 = hittable_types[_t2];
        if (!variable_struct_exists(global.enemy_by_type, _key2)) continue;
        var _list2 = global.enemy_by_type[$ _key2];
        for (var _i2 = 0; _i2 < array_length(_list2); _i2++)
        {
            var _e2 = _list2[_i2];
            if (!instance_exists(_e2) || _e2.hp <= 0) continue;
            if (_e2.grid_col != col || _e2.grid_row != row) continue;

            var _d = abs(_e2.x - tx);
            if (_best == noone || _d < _best_d)
            {
                _best = _e2;
                _best_d = _d;
            }
        }
    }

    if (_best != noone)
    {
        with (_best)
        {
            damage_amount = other.damage;
            damage_type = other.damage_type;
            event_user(0);
        }
    }
}

instance_destroy();
