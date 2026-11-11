// obj_yuanqiniu（元气牛 / 泡泡元气牛 / 酷酷元气牛）Create 事件
// 喷壶类·旋转喷壶类：每 cycle 帧（1.8→1.4 秒）向周围散一圈气泡波，
//   范围 3*3 / 5*5 / 5*5，波数 1 / 1 / 2（2 转一轮两波，伤害平分）
//   最终攻击力 = 基础 × [1 + 0.1 × (场上同形态数量 - 1)]，11 只到上限 2 倍
// 数值：同类加成 / 加成上限 走 custom 标量；波数 / 范围 / 「每波怎么分」写在下面（实现参数）
//   ⚠️ xlsx 的攻击力列是**一轮总伤害**，所以每波 = 总伤害 ÷ 波数
// 素材 27 帧：没有干净的「待机段 / 攻击段」，气泡帧和小身位帧是交替的，
//   所以按像素量把它们拆成两组（下面 yn_idle_frames / yn_bub_frames），待机播前者、攻击播后者
event_inherited();

plant_id = "yuanqiniu";
obj_type = object_index;
event_user(0);

if (shape == 0)      sprite_index = spr_yuanqiniu;
else if (shape == 1) sprite_index = spr_yuanqiniu_1;
else                 sprite_index = spr_yuanqiniu_2;

plant_type   = "normal";
feature_type = "normal";
target_type  = "rotate";      // 旋转喷壶类：范围内全方位，可打 dance / underground
is_slowdown  = false;
image_speed  = 0;             // 帧自己推
flash_speed  = 5;

// ── 范围：3*3 / 5*5 / 5*5 ──
range_cols = (shape >= 1) ? 2 : 1;
range_rows = (shape >= 1) ? 2 : 1;

// ── 帧分组（按像素量自动拆的，见文件头注释；要改帧位就动这两行）──
var _idle_sets = [
    [0, 2, 5, 6, 7, 9, 10, 11, 12, 13, 15, 17, 18, 20, 22, 23, 24, 25, 26],
    [0, 2, 3, 4, 5, 7, 8, 9, 11, 12, 13, 15, 16, 18, 19, 20, 21, 22, 23, 24],
    [0, 1, 2, 3, 5, 7, 8, 9, 11, 13, 14, 15, 17, 18, 19, 20, 21, 23, 26]
];
var _bub_sets = [
    [1, 3, 4, 8, 14, 16, 19, 21],
    [1, 6, 10, 14, 17, 25, 26],
    [4, 6, 10, 12, 16, 22, 24, 25]
];
var _si = min(shape, 2);

yn_idle_frames = _idle_sets[_si];
yn_bub_frames  = _bub_sets[_si];

yn_use_bub   = false;         // false = 待机组，true = 气泡组
yn_frame_i   = 0;
yn_frame_t   = 0;
image_index  = yn_idle_frames[0];
idle_anim    = 26;            // 父对象推帧要读（实际帧由下面两组自己推）
attack_anim  = 0;
yn_same_tmp  = 0;

// ── 注册表 custom ──
// 波数 1 / 1 / 2：写死（按形态固定，不进 custom）
yn_waves = (shape >= 2) ? 2 : 1;

// 同类加成：每张 +10%，上限 2 倍（11 只）—— 固定值，写死
yn_bonus = 0.10;
yn_cap   = 2.0;
yn_atk_mult  = 1.0;
yn_wave_gap  = 54;           // 开火时按 cycle 重算（Create 阶段 cycle 还是 0）

// ── 攻击状态 ──
yn_timer      = 0;
yn_waves_left = 0;
yn_wave_t     = 0;
yn_dmg        = 0;
