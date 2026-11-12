/// 钢爪窃蛋龙 / 铁甲窃蛋龙 / 岩甲窃蛋龙（qiedanlong）Create 事件
/// 投掷类·多线投手：向前方 3 行投掷带溅射的龙蛋
///   0 转：中路 1 发｜1 转：中路 2 发｜2 转：3 行各 1 发（中路 2 发）
///   未命中也会爆炸（落地即炸）
/// 溅射固定「攻击力 × 35%」→ 写死；子弹数只是情报岛文案，实际发数见下面的三路表
event_inherited();

plant_id = "qiedanlong";
obj_type = object_index;
event_user(0);

if (shape == 0)      sprite_index = spr_qiedanlong;
else if (shape == 1) sprite_index = spr_qiedanlong_1;
else                 sprite_index = spr_qiedanlong_2;

plant_type   = "normal";
feature_type = "normal";
target_type  = "throw";
is_slowdown  = false;
image_speed  = 0;
flash_speed  = 5;

// 2026-11-12 用户口径：待机 = 第 1~11 帧（index 0~10），攻击 = 第 12~20 帧（index 11~19，9 帧）
idle_anim   = 10;
attack_anim = 9;

attack_timer = 0;
state        = CARD_STATE.IDLE;

// ── 可调参数 ──
qd_art_up     = 125;       // 出膛抬高
qd_throw_ft   = 45;        // 基准飞行帧数
qd_lane_off   = 0;         // 由注册行数决定（见 Other_11）
qd_fired      = false;

// ── 溅射：固定「攻击力 × 35%」，三形态一样 → 写死，不进 custom ──
qd_splash_ratio = 0.35;
qd_splash_cells = 1;          // 3*3 溅射

// 每行发数：三路合计 3 / 4 / 6（xlsx 子弹数）
//   0 转 1+1+1 ｜ 1 转 1+2+1 ｜ 2 转 2+2+2
//   custom 里的「子弹数」只是情报岛文案，实际发数由下面这张表决定（合计与它一致）
qd_lane_rows = [-1, 0, 1];
if (shape == 0)      qd_lane_n = [1, 1, 1];
else if (shape == 1) qd_lane_n = [1, 2, 1];
else                 qd_lane_n = [2, 2, 2];
