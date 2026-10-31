// obj_eightcake_bomb Step 事件
if (global.is_paused) exit;

// ===== 爆炸段：播 7~13，播完消失 =====
if (landed)
{
    boom_t++;
    image_index = 7 + min(floor(boom_t / 3), 6);
    if (boom_t > 21) instance_destroy();
    exit;
}

// 飞行段自己推帧，只在 0~fly_end（0~6）之间循环 —— 不许靠 image_speed 自动推进，
//   否则会越过 fly_end 把「爆炸帧」播在空中（用户反馈「飞着就炸了」）
t++;
image_index = (t div 3) mod (fly_end + 1);
var _p = min(1, t / T);
x = lerp(sx, tx, _p);
y = lerp(sy, ty, _p) - arc * 4 * _p * (1 - _p);

if (t < T) exit;

// ===== 落地：3*3 灰烬爆炸 =====
landed = true;
x = tx;
y = ty;
image_index = 7;

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
            if (abs(_e.grid_col - col) > 1 || abs(_e.grid_row - row) > 1) continue;

            with (_e)
            {
                if (is_boss || (immune_to_ash && hp > other.damage))
                {
                    hp -= other.damage;
                    event_user(0);
                }
                else
                {
                    instance_create_depth(x, y - 20, depth, obj_mouse_ash_death);
                    instance_destroy();
                }
            }
        }
    }
}

// 清掉范围内的梯子（与 obj_coke_bomb 同口径）
with (obj_ladder)
{
    if (host_plant != noone && instance_exists(host_plant))
    {
        if (abs(host_plant.grid_col - other.col) <= 1 && abs(host_plant.grid_row - other.row) <= 1)
        {
            instance_destroy();
        }
    }
}

if (global.screen_shake) Camera_Shock(5, 20);
