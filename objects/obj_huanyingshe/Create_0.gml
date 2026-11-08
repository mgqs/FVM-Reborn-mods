// obj_huanyingshe（幻影蛇 / 羽翼幻影蛇 / 金盔幻影蛇）Create 事件
// 投掷类·多线投手（2026-11-07 新卡）
//   前方 3 行（二转 5 行）各投 1 发追踪蛇蛋（二转共 6 发），命中 3×3 溅射，比例 30% / 45% / 45%。
event_inherited();

plant_id = "huanyingshe";
obj_type = object_index;
event_user(0);

if (shape == 0)      sprite_index = spr_huanyingshe;
else if (shape == 1) sprite_index = spr_huanyingshe_1;
else                 sprite_index = spr_huanyingshe_2;

plant_type   = "normal";
feature_type = "normal";
target_type  = "throw";
is_slowdown  = false;
image_speed  = 0;
flash_speed  = 5;

attack_timer = 0;
state        = CARD_STATE.IDLE;

// 2026-11-08：三套精灵统一修剪成 27 帧 —— 待机 1~13（索引 0~12，期间没有蛋）
//   + 攻击 14~26（索引 13~25，其中第 14 帧蛋出现）
//   + **第 27 帧（索引 26）= 与待机同姿势的防闪缓冲帧**（不是重复帧，用户明确要留）
//   攻击段里 20 帧（索引 19）正好是蛋丢出去那一帧 → 子弹在那时候才出膛。
idle_anim   = 11;   // 待机 0~12（13 帧）
attack_anim = 15;   // 攻击 13~26（13 蛋帧 + 1 防闪缓冲）
anim_t      = 0;

// 出弹帧（索引）：第 20 帧 = 蛋离嘴。只写 fire_frame 不够，Step 必须判 image_index >= fire_frame。
fire_frame        = 19;
huanyingshe_fired = false;

row_span   = (shape >= 2) ? 2 : 1;     // 上下各几行（二转 5 行）
egg_count  = (shape >= 2) ? 6 : 3;     // 二转子弹 +3

// 溅射比例：走注册表 custom["溅射比例"]（0 转 0.30 / 1·2 转 0.45），改表即生效。
//   子弹伤害 = atk（已吃投手增幅倍率）→ 溅射 = damage × 比例，所以**天然吃拐**。
var _sk   = variable_instance_exists(id, "skill") ? skill : 0;
var _info = get_plant_data_with_skill("huanyingshe", shape, clamp(current_level, 0, 16), _sk);
splash_ratio = (shape == 0) ? 0.30 : 0.45;
if (_info != undefined && ds_map_exists(_info, "溅射比例")) splash_ratio = _info[? "溅射比例"];
