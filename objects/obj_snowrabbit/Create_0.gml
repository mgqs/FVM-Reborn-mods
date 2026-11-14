/// 雪球兔 / 冰霜雪球兔 / 暴风雪球兔（snowrabbit）Create 事件
/// 追踪类·散点追踪：冷却 15 秒，一次召唤 5 / 5 / 8 颗雪球同时砸向全屏目标
///   1 转起：场上每多 1 张同形态雪球兔，攻击力 +8%，9 只后到达上限 1.64 倍
///   2 转：命中附加 3*3 范围 20% 溅射
/// 数值走注册表：攻击上限 / 同类加成 / 加成上限 → custom 标量；2 转溅射固定 20% → 写死
event_inherited();

plant_id = "snowrabbit";
obj_type = object_index;
event_user(0);

if (shape == 0)      sprite_index = spr_snowrabbit;
else if (shape == 1) sprite_index = spr_snowrabbit_1;
else                 sprite_index = spr_snowrabbit_2;

plant_type   = "normal";
feature_type = "normal";
target_type  = "all";        // 与冷萃机一致：全类型（含地鼠 underground）
is_slowdown  = false;
image_speed  = 0;
flash_speed  = 5;

// 2026-11-12 用户口径：待机 = 第 1~10 帧（index 0~9），攻击 = 第 11~22 帧（index 10~21，12 帧）
idle_anim   = 9;
attack_anim = 12;

attack_timer = 0;
state        = CARD_STATE.IDLE;
sr_firing    = false;

// ── 可调参数 ──
sr_art_up     = 60;
// 2026-11-13：出弹绑「攻击动画第 17 帧」——雪球这时候才砸下来，之后动画继续播到第 22 帧收尾
//   （原来按 cycle 末尾 -5 帧出弹，等于动画放完才落球，全落在后摇里）
sr_fire_index = 17;

// ── 注册表 custom ──
var _sk   = variable_instance_exists(id, "skill") ? skill : 0;
var _info = get_plant_data_with_skill("snowrabbit", shape, clamp(current_level, 0, 16), _sk);

sr_target_max   = 5;                          // 攻击上限（custom 标量 5 / 5 / 8）
sr_splash_ratio = (shape >= 2) ? 0.20 : 0;    // 2 转 3*3 20% 溅射：攻击力 × 20%，写死
// 同类加成：1 转起每张 +8%，上限 1.64 倍（9 只）—— 固定值，写死
sr_same_bonus   = (shape >= 1) ? 0.08 : 0;
sr_cap          = (shape >= 1) ? 1.64 : 1;
if (_info != undefined && ds_map_exists(_info, "攻击上限")) sr_target_max = _info[? "攻击上限"];
sr_splash_cells = 1;

// ── 同类加成：场上同形态雪球兔数量（含自己） ──
sr_same_count = 0;
with (obj_snowrabbit){
    if (shape == other.shape) other.sr_same_count++;
}
sr_same_count = max(1, sr_same_count);
sr_atk_mult   = 1 + sr_same_bonus * (sr_same_count - 1);
// 上限走 custom["加成上限"]（1 转起 1.64 = 9 只）
if (sr_atk_mult > sr_cap) sr_atk_mult = sr_cap;

// 2026-11-13 用户口径：同类增伤直接抬「初始攻击力 base_atk」（再被增幅一起放大）
sr_atk_base    = -1;          // 不含同类加成的基准（首帧 Step 取 base_atk）
sr_atk_written = -1;          // 上一次写出去的 base_atk
