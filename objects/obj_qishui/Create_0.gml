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

idle_anim   = 12;
attack_anim = 10;

attack_timer = 0;
state        = CARD_STATE.IDLE;

// ── 可调参数 ──
qs_burst_left  = 0;
qs_burst_timer = 0;
qs_burst_gap   = 8;
qs_art_up      = -30;
qs_muzzle_x    = 40;
qs_lead        = 4;
qs_fire_delay  = 1;

// ── 注册表 custom（标量：子弹数 1/2/3、弹射次数、减速时间 0/2/2）──
//   弹射倍率「2 倍伤害」三形态都是攻击力×2 → 写死，不进 custom
var _sk   = variable_instance_exists(id, "skill") ? skill : 0;
var _info = get_plant_data_with_skill("qishui", shape, clamp(current_level, 0, 16), _sk);

qs_bounce_times = 3;      // 总计命中 3 只 —— 固定值，写死
qs_bounce_mult  = 2;      // 弹射倍率（攻击力 × 2）
qs_bounce_cells = (shape >= 2) ? 2 : 1;   // 弹射范围 3*3 / 3*3 / 5*5
qs_slow_time    = (shape >= 1) ? 2 : 0;   // 1 转起命中减速 2 秒
qs_shot_count   = (shape >= 2) ? 3 : ((shape == 1) ? 2 : 1);
if (_info != undefined && ds_map_exists(_info, "子弹数")) qs_shot_count = _info[? "子弹数"];
qs_slow_frames = round(qs_slow_time * 60);
qs_ice_death   = (shape >= 2);   // 2 转：击杀碎冰
