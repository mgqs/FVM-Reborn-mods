// obj_zhuanlonghu（转龙壶 / 充能转龙壶 / 巨星转龙壶）Create 事件
// 辅助类·冷却类：放下后走「前摇 2.3 → 0.7 秒」（register_card_skill 的「前摇」9 档），
//   到点把 3*3 / 3*3 / 5*5 范围内**正在冷却的实体卡**剩下的冷却加上「总冷却 × 30/50/50%」，然后自己消失
//   对已经冷却完毕的卡、非实体卡（合体 / 变身中的）不生效（xlsx 原文）
// 数值：冷却缩减走 custom["冷却缩减"]（30/50/50）；范围写在下面（实现参数，不进 custom）
// 写法照 obj_meiweijishiqi（同一族机制），差别只有：只结算一次、不建脚下光效（没素材）
event_inherited();

plant_id = "zhuanlonghu";
obj_type = object_index;
event_user(0);

if (shape == 0)      sprite_index = spr_zhuanlonghu;
else if (shape == 1) sprite_index = spr_zhuanlonghu_1;
else                 sprite_index = spr_zhuanlonghu_2;

plant_type   = "coffee";      // 冷却类：老鼠不啃、不吃海水（同极寒冰沙 / 计时器）
feature_type = "normal";
target_type  = "normal";
is_slowdown  = false;
image_speed  = 0;
flash_speed  = 5;

idle_anim   = 15;             // 素材 16 帧全待机
attack_anim = 0;

// ── 待机帧 ──
zl_anim_i    = 0;
zl_anim_tick = 0;
image_index  = 0;

// ── 范围：3*3 / 3*3 / 5*5 ──
zl_range_col = (shape >= 2) ? 2 : 1;
zl_range_row = (shape >= 2) ? 2 : 1;

// ── 前摇：技能 9 档，走 register_card_skill("zhuanlonghu", "前摇", [...]) ──
// ── 冷却缩减：按形态固定 30 / 50 / 50（custom 标量，情报岛 {冷却缩减} 用）──
zl_reduce_pct   = (shape >= 1) ? 50 : 30;
zl_reduce_ratio = zl_reduce_pct / 100;
zl_cast_delay   = 138;
zl_init_done    = false;
zl_timer        = 0;
zl_cast_done    = false;
