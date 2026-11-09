// obj_huanyingshe_bullet Step 事件
// 飞行 → 到点 / 命中 → 碎片段 → 销毁。
//   2026-11-08 重写：原来竖直方向落不到目标高度（永远到不了 land_y），会一路飞过头再掉到别的行，
//   而且落点靠 world→grid 反推 → 溅射中心错行，实机表现就是「投了但打不中」。
if (global.is_paused) exit;

// 碎片段：停在爆点播完再销毁（伤害进这一段之前已经结算完）
if (exploding)
{
    explode_t++;
    image_index = hit_first + min(hit_last - hit_first, explode_t div 4);
    if (explode_t >= (hit_last - hit_first + 1) * 4) instance_destroy();
    exit;
}

life++;

// 追踪：目标还活着 → 每帧把落点和爆点格子跟着它更新（移动的老鼠也落得到、溅射不会错行）
if (instance_exists(target_id) && target_id.hp > 0)
{
    land_x = target_id.x;
    land_y = target_id.y - 45;
    grid_target_row = target_id.grid_row;
    grid_target_col = target_id.grid_col;
}

// 参数化抛物线：位置 = 起点→落点插值 - 弧高 × sin(pi·p)
var _p = min(1, life / max(1, land_frame));
x = lerp(start_x, land_x, _p);
y = lerp(start_y, land_y, _p) - arc_h * sin(pi * _p);
image_angle = -life * 6;      // 蛋在空中慢慢翻

// ── 命中：只判「自己这一路」+ 只在过了弧顶开始下落之后 ──
//   2026-11-08 实机反馈：蛋飞到上面两行就被那里的老鼠撞碎，伤害也记在那只身上；远处 / 场外目标同样半路炸。
//   根因：起点 y-120、弧高 140 → 弧顶在卡上方约 1.2 格（格子高 116），前半段整条轨迹横穿**上面两行**老鼠的判定框，
//        而这里原来从第 1 帧就对所有行做 bbox 命中 → 谁先碰上谁先炸，蛋根本到不了目标那一行。
//   修法：① 只认 grid_row == grid_target_row（这一发蛋分到的那一路）② _p >= 0.5（过了弧顶）才判定。
//   不动：弧高 arc_h / 起手高度 / 落点逐帧追踪 / 溅射口径（投手 200px、行 ±1）。
var _hit_e = noone;
hit_tick++;
if (_p >= 0.5 && hit_tick >= global.bullet_hit_interval && bullet_enemy_reachable(id))
{
    hit_tick = 0;
    for (var _t = 0; _t < array_length(hittable_types); _t++)
    {
        var _key  = hittable_types[_t];
        var _list = bullet_sap_type_list(id, _key);
        for (var _i = 0; _i < array_length(_list); _i++)
        {
            var _e = _list[_i];
            if (!instance_exists(_e) || _e.hp <= 0) continue;
            if (!variable_instance_exists(_e, "grid_row")) continue;
            if (_e.grid_row != grid_target_row) continue;
            if (precise_bbox_collision(id, _e))
            {
                _hit_e = _e;
                break;
            }
        }
        if (instance_exists(_hit_e)) break;
    }
}

var _boom = (_p >= 1) || (life > max_life);
if (instance_exists(_hit_e))
{
    grid_target_row = _hit_e.grid_row;
    grid_target_col = _hit_e.grid_col;
    _boom = true;
}

if (_boom)
{
    var _dmg = damage;
    var _rat = splash_ratio;
    var _cx  = x;
    var _cy  = y;
    // 🔴 爆点格子必须先存成局部变量：下面两处都写在 with (obj_enemy_parent) 里，
    //    直接写 grid_target_row 会被解析成「老鼠的」变量 → Variable obj_xxx.grid_target_row not set（2026-11-08 崩过）
    var _tr  = grid_target_row;
    var _tc  = grid_target_col;

    // ① 直接命中的那只吃满额（没撞到就取落点格子里最近的一只）
    var _main = instance_exists(_hit_e) ? _hit_e : noone;
    if (instance_exists(_main))
    {
        _cx = _main.x;
        _cy = _main.y;
    }
    else
    {
        var _md = 999999;
        with (obj_enemy_parent)
        {
            if (hp <= 0) continue;
            if (grid_row != _tr || grid_col != _tc) continue;
            var _d = point_distance(other.x, other.y, _cx, _cy);
            if (_d < _md){ _md = _d; _main = id; }
        }
        if (instance_exists(_main)){ _cx = _main.x; _cy = _main.y; }
    }

    if (instance_exists(_main))
    {
        with (_main)
        {
            damage_amount = _dmg;
            damage_type   = "throw";
            event_user(0);
        }
    }
    var _main_id = instance_exists(_main) ? _main.id : noone;

    // ② 溅射：**投手口径**（同煮蛋器 / 索尔，2026-11-08 用户口径）
    //    半径 200px、本行 ±1 行、can_hit 过滤（throw = 普通 + 潜水）、排除直接命中的那只
    with (obj_enemy_parent)
    {
        if (hp <= 0) continue;
        if (id == _main_id) continue;
        if (abs(grid_row - _tr) > 1) continue;
        if (point_distance(x, y, _cx, _cy) >= 200) continue;
        if (!can_hit("throw", target_type)) continue;

        damage_amount = round(_dmg * _rat);
        damage_type   = "throw";
        event_user(0);
    }

    // 命中音：2026-11-08 用户口径 —— 换成煮蛋投手的「蛋碎裂」音（原来是火系命中音 snd_fire_hit）
    audio_play_sound(snd_egg_bullet, 0, 0);

    exploding   = true;
    explode_t   = 0;
    image_index = hit_first;
    image_angle = 0;
    exit;
}
