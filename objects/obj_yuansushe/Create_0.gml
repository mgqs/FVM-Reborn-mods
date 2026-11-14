// obj_yuansushe（元素蛇 / 烈暴元素蛇 / 流星元素蛇）Create 事件
// 直射类·直线穿透类（2026-11-13 新卡，素材 = 桌面\皮特\11月份做卡11.12\spr-yuansushe）
//   官方口径（米苏.jpg + 数据信息.xlsx 第 63~72 行）：
//     向本行前方发射 1 发带有不同效果的穿透子弹；耗能 290 / 范围 1 行 / 全天。
//     子弹可以反弹、可过障碍，但不受火盆类影响（冰弹不会失去减速）。
//     发射某种子弹前眼睛会变成该子弹的颜色。
//     0 转循环 黄 → 紫 → 蓝 → 红（每发 1 颗）；
//     1 转同循环，元素效果提升；2 转「黄+红 / 紫+红 / 蓝+红 / 红+红」（每发 2 颗，第二颗恒红）。
//   四色效果（0/1/2 转三档）：
//     黄 5% / 10% / 10% 概率定身 1.5 秒
//     紫 30% / 50% / 50% 概率产生 1 次 300 / 450 / 450 伤害的毒气
//     蓝 30% / 50% / 50% 概率冰冻 2 秒后减速 2 秒
//     红 30% / 50% / 50% 概率造成 2 / 3 / 3 倍伤害
//
// ── 素材切分（重要）──────────────────────────────────────────────────────
//   每个形态的精灵都是 84 帧 = **4 段 × 21 帧**，一段一种眼睛颜色：
//     段 1 黄（帧 1~21）/ 段 2 紫（22~42）/ 段 3 蓝（43~63）/ 段 4 红（64~84）
//   段内结构一致：待机 1~13（idx 0~12）+ 攻击 14~21（idx 13~20）。
//   所以导入时按段拆成 4 个精灵（spr_yuansushe / _p / _b / _r），换色 = 换 sprite_index，
//   动画下标完全一致，父对象的 idle/attack 区间不用跟着变。
event_inherited();

plant_id = "yuansushe";
obj_type = object_index;
event_user(0);

plant_type   = "normal";
feature_type = "normal";
// 穿透：能打 普通 + 非主流 + 障碍 + 未显形幽灵（同双刃蛇 / 天蝎座），不打空军 / 潜水 / 钻地
target_type  = "pierce";
is_slowdown  = false;
image_speed  = 0;      // 🔴 必须 0：帧由父对象 timer 推
flash_speed  = 5;

idle_anim   = 12;      // 待机 idx 0~12（帧 1~13）
attack_anim = 8;       // 攻击 idx 13~20（帧 14~21）
state       = CARD_STATE.IDLE;
attack_timer = 0;

// ── 四色精灵表（形状 × 颜色）──────────────────────────────────
if (shape == 0)
    ys_color_spr = [spr_yuansushe,   spr_yuansushe_p,   spr_yuansushe_b,   spr_yuansushe_r];
else if (shape == 1)
    ys_color_spr = [spr_yuansushe_1, spr_yuansushe_1_p, spr_yuansushe_1_b, spr_yuansushe_1_r];
else
    ys_color_spr = [spr_yuansushe_2, spr_yuansushe_2_p, spr_yuansushe_2_b, spr_yuansushe_2_r];

if (shape == 0)
    ys_bullet_spr = [spr_yuansushe_bullet,   spr_yuansushe_bullet_p,   spr_yuansushe_bullet_b,   spr_yuansushe_bullet_r];
else if (shape == 1)
    ys_bullet_spr = [spr_yuansushe_1_bullet, spr_yuansushe_1_bullet_p, spr_yuansushe_1_bullet_b, spr_yuansushe_1_bullet_r];
else
    ys_bullet_spr = [spr_yuansushe_2_bullet, spr_yuansushe_2_bullet_p, spr_yuansushe_2_bullet_b, spr_yuansushe_2_bullet_r];

// 眼睛颜色 = **下一发**要打出去的子弹颜色（原版就是这么表现的）
ys_eye          = 0;
ys_pending_eye  = -1;   // 打完一发后要切到的颜色；-1 = 无待切换
sprite_index    = ys_color_spr[ys_eye];

// ── 循环表 ───────────────────────────────────────────────────
//   0/1 转：每次 1 颗，颜色 0→1→2→3 循环
//   2 转：每次 2 颗，第一颗颜色 0→1→2→3 循环、第二颗恒红（3）
ys_step        = 0;     // 循环进度 0~3
ys_bullet_count = (shape >= 2) ? 2 : 1;
ys_second_color = 3;

// ── 效果三档（下标 = shape，上限夹到 2）──────────────────────
var _tier = min(shape, 2);
var _pin_tab     = [0.05, 0.10, 0.10];
var _ele_tab     = [0.30, 0.50, 0.50];
var _poison_tab  = [300, 450, 450];
var _crit_tab    = [2, 3, 3];

ys_pin_chance    = _pin_tab[_tier];
ys_pin_ticks     = 90;                                   // 定身 1.5 秒
ys_poison_chance = _ele_tab[_tier];
ys_poison_damage = _poison_tab[_tier];
ys_freeze_chance = _ele_tab[_tier];
ys_freeze_ticks  = 120;                                  // 冰冻 2 秒
ys_slow_ticks    = 240;                                  // 减速总计 2+2 秒（冰冻期间一并倒计时）
ys_crit_chance   = _ele_tab[_tier];
ys_crit_mult     = _crit_tab[_tier];

ys_bullet_speed = 9;
ys_end_col      = global.grid_cols + 1;   // 飞出这一列就消散

/// 索敌：本行前方（含自身格）有没有可打目标
ys_has_target = function()
{
    var _hit = false;
    with (obj_enemy_parent)
    {
        if (hp > 0
            && grid_row == other.grid_row
            && grid_col >= other.grid_col
            && grid_col <= global.grid_cols + 1
            && can_target_on(other.target_type, target_type))
        {
            _hit = true;
            break;
        }
    }
    return _hit;
};

/// 出一发子弹：_color = 0 黄 / 1 紫 / 2 蓝 / 3 红；_delay = 第 2 颗的错帧
ys_fire_one = function(_color, _delay)
{
    // 出膛口 = 蛇嘴，但要压在**老鼠头顶那一带**：
    //   素材 62x87、原点在底边中心 (30,85)、嘴约在 sprite y≈41 → 距原点 44px、卡片按 1.8 倍画，
    //   所以「嘴里」在世界坐标是 y-79。可 y-79 时子弹盒落在 [中心-96, 中心-60]，
    //   而敌人出生点是「格心 +38、原点在脚底」，矮鼠（蝙蝠 88 / 障碍 63）的头顶只到 中心-50，
    //   整条弹道都在它们头顶之上 —— 视觉上就是「子弹从老鼠头上飘过去，什么都没发生」。
    //   y-50 让子弹盒落进 [中心-105, 中心-68]（相对敌人原点 = [-67, -30]），
    //   与 63(障碍) / 88(蝙蝠) / 104(黄瓜) / 128(木桶) 四种常见身高全都相交，
    //   同时还在蛇头范围内，不至于像从肚子中间飞出来。
    var _b = instance_create_depth(x + 46, y - 50, depth - 500, obj_yuansushe_bullet);
    _b.sprite_index = ys_bullet_spr[_color];

    _b.row        = grid_row;
    _b.ys_color   = _color;
    _b.damage     = atk;
    _b.move_speed = ys_bullet_speed;
    _b.ys_end_col = ys_end_col;
    _b.ys_delay   = _delay;

    _b.ys_pin_chance    = ys_pin_chance;
    _b.ys_pin_ticks     = ys_pin_ticks;
    _b.ys_poison_chance = ys_poison_chance;
    _b.ys_poison_damage = ys_poison_damage;
    _b.ys_freeze_chance = ys_freeze_chance;
    _b.ys_freeze_ticks  = ys_freeze_ticks;
    _b.ys_slow_ticks    = ys_slow_ticks;
    _b.ys_crit_chance   = ys_crit_chance;
    _b.ys_crit_mult     = ys_crit_mult;
};
