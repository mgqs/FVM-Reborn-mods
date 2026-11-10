// obj_tianxie_alt Step：沿本行往右飞 → 碰到第一只可打老鼠就结算并自毁
if (global.is_paused) exit;

// ── 第一次 Step 配贴图 / 缩放 / 绘制偏移（tx_alt_spawn 是「先创建、后赋 alt_mode」）──
if (!alt_ready)
{
    alt_ready = true;
    if (alt_mode == "cow")
    {
        // spr_nizhuanniu_2：内容中心 (103, 102.5)，原点 (104, 133)，内容 64×71
        sprite_index = spr_nizhuanniu_2;
        alt_scale = 1.099;                  // 78 / 71（转 90° 后屏上宽度 = 内容高 × scale）
        alt_dx    = (-30.5) * alt_scale;    // (cy - oy)
        alt_dy    = -(-1.0) * alt_scale;    // -(cx - ox)
    }
    else
    {
        // spr_guihuajiu_2：内容中心 (178, 150)，原点 (178, 189)，内容 74×80
        sprite_index = spr_guihuajiu_2;
        alt_scale = 0.975;                  // 78 / 80
        alt_dx    = (-39) * alt_scale;
        alt_dy    = -(0) * alt_scale;
    }
}

x += alt_speed;
alt_life++;

// 飞到底还没碰到东西 → 自己消失（不结算）
if (alt_life > 900 || x > room_width + 200)
{
    instance_destroy();
    exit;
}

// ── 碰第一只 ──
//   行必须相等；cow 只认 normal / 钻地且 BOSS 免疫；wine 只要是「站在地面那一行」的活老鼠就触发
//   ⚠️ 两张都不许凭空扩大原卡能打的类型：
//      · cow（逆转牛）原版只搬 normal + 钻地、不碰 BOSS
//      · wine（桂花酒）原版是「站在命中格里的老鼠」才炸/醉酒 → 这里挡掉 air（飞行鼠不在格上）
//        和 obstacle（障碍不是老鼠，原版炸到它只是巧合，不当触发条件）
var _hit   = noone;
var _hit_x = 999999;
with (obj_enemy_parent)
{
    if (hp <= 0) continue;
    if (grid_row != other.alt_row) continue;

    if (other.alt_mode == "cow")
    {
        if (is_boss) continue;
        if (target_type != "normal" && target_type != "underground") continue;
    }
    else
    {
        if (target_type == "air" || target_type == "obstacle") continue;
    }

    if (abs(other.x - x) > other.alt_hit_range) continue;

    if (x < _hit_x)
    {
        _hit_x = x;
        _hit   = id;
    }
}

if (instance_exists(_hit))
{
    alt_trigger(_hit);
    instance_destroy();
}
