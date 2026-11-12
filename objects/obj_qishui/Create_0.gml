/// 弹珠汽水 / 冰镇弹珠汽水 / 晶珠弹珠汽水（qishui）Create 事件
/// 直射类·弹射：直线弹命中后产生 2 倍伤害的弹射子弹，
///   弹射子弹每次向「当前目标格」周围 3*3 / 3*3 / 5*5 范围内最近的目标弹射，总计 3 只
/// 1 转起命中附加减速；2 转击杀产生碎冰效果
/// 数值走注册表：子弹数 / 弹射次数 / 减速时间 → custom 标量；弹射倍率固定 2 倍 → 写死
event_inherited();

plant_id = "qishui";
obj_type = object_index;
event_user(0);

if (shape == 0)      sprite_index = spr_qishui;
else if (shape == 1) sprite_index = spr_qishui_1;
else                 sprite_index = spr_qishui_2;

plant_type   = "normal";
feature_type = "normal";
target_type  = "normal";
is_slowdown  = false;
attack_type  = ATTACK_TYPE.SHOOTER;
image_speed  = 0;
flash_speed  = 5;

// 🔴 2026-11-12 第二轮：素材原本两段尺寸不一致（1~20 攻击段、21~32 待机段，待机大 1.49 倍），
//   播到待机段就像「突然放大」。现已按待机为准把攻击段整体放大 1.486 倍对齐脚底，
//   并按「待机 12 帧 + 攻击 20 帧」重排为 32 帧（卡面 = 待机首帧，即原第 21 帧）：
//     待机 f0~f11（12 帧）→ idle_anim = 11
//     攻击 f12~f31（20 帧）→ attack_anim = 20（20 × flash 5 = 100 帧 ≤ cycle 120）
idle_anim   = 11;
attack_anim = 20;

attack_timer = 0;
state        = CARD_STATE.IDLE;

// ── 可调参数 ──
qs_burst_left  = 0;
qs_burst_timer = 0;
qs_burst_gap   = 8;
qs_art_up      = -30;
qs_muzzle_x    = 40;
qs_fire_delay  = 1;

// 2026-11-13：吐出子弹的那一帧 = 精灵第 30 帧（index 29）。
//   以前用 qs_lead「提前 4 帧切攻击姿势」猜时间，cycle 一短（高技能 / 减速）动画还没走到第 30 帧子弹就出去了。
//   现在 Step 按这个 index 反推动画步长，保证「播到第 30 帧」与「出弹」落在同一帧。
qs_spit_index  = idle_anim + 18;   // 11 + 18 = 29 → 第 30 帧
qs_anim_t      = 0;                // 攻击动画已推进的帧数（自己算，不依赖父对象推帧）
qs_anim_span   = 40;               // 攻击动画占多少帧（从开始摆姿势到吐出子弹）。40/17 ≈ 每 2 帧过一张；
                                   // 调大 → 前摇更慢、待机时间变短；调小 → 更利落（别再让它占满整个 cycle）

// ── 注册表 custom（标量：子弹数 1/2/3、弹射次数、减速时间 0/2/2）──
//   弹射倍率「2 倍伤害」三形态都是攻击力×2 → 写死，不进 custom
var _sk   = variable_instance_exists(id, "skill") ? skill : 0;
var _info = get_plant_data_with_skill("qishui", shape, clamp(current_level, 0, 16), _sk);

qs_bounce_times = 3;      // 总计命中 3 只 —— 固定值，写死
qs_bounce_mult  = 1;      // 弹射段伤害倍率：弹射 = 攻击表原值（直射才是 2 倍）
qs_direct_mult  = 2;      // 直射段伤害倍率：攻击表 × 2（2026-11-13 用户口径）
qs_bounce_cells = (shape >= 2) ? 2 : 1;   // 弹射范围 3*3 / 3*3 / 5*5
qs_slow_time    = (shape >= 1) ? 2 : 0;   // 1 转起命中减速 2 秒
qs_shot_count   = (shape >= 2) ? 3 : ((shape == 1) ? 2 : 1);
if (_info != undefined && ds_map_exists(_info, "子弹数")) qs_shot_count = _info[? "子弹数"];
qs_slow_frames = round(qs_slow_time * 60);
qs_ice_death   = (shape >= 2);   // 2 转：击杀碎冰
