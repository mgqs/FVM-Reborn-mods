// obj_yuanqiniu（元气牛 / 泡泡元气牛 / 酷酷元气牛）Create 事件
// 喷壶类·旋转喷壶类：每 cycle 帧（1.8→1.4 秒）向周围散一圈气泡波，
//   范围 3*3 / 5*5 / 5*5
//   最终攻击力 = 基础 × [1 + 0.1 × (场上同形态数量 - 1)]，11 只到上限 2 倍
// 数值：同类加成 / 加成上限 / 范围 写死或走 custom 标量
//   ⚠️ xlsx 的攻击力列是**一轮总伤害** → 一轮里分两次结算（第一波 + 第二波各一半，奇数第二波补差）
// 素材 27 帧（三形态一致）：
//   编辑器第 1~11 帧 = 待机呼吸（index 0~10）
//   第 12 帧起势 → 13~14 蓄力 → 15~21 第一波气泡（第 21 帧张满，index 20）
//   → 22 起第二波 → 22~27 第二波（第 27 帧张满，index 26）
//   攻击段 = 第 12~27 帧（index 11~26，共 16 帧），整段播完再回待机
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

// ── 帧段（口径同 obj_xuanzhuan_ronghe：只存段首 / 段长 / 结算帧，不列帧组）──
//   下面注释里的「第 N 帧」= 编辑器帧号（1 基）；代码里的值一律是 index（0 基）
SEG_IDLE_LEN  = 11;           // 待机：第 1~11 帧（index 0~10）
SEG_ATK_FIRST = 11;           // 攻击段首帧 = 第 12 帧（index 11，起势）
SEG_ATK_LEN   = 16;           // 第 12~27 帧（index 11~26）共 16 帧，两波气泡整段播完
// 结算帧（相对攻击段首帧的偏移，0 基）：第 20 / 26 帧 = 两波气泡各自张满前一点
//   第 20 帧 → index 19 → 19 - 11 = 8；第 26 帧 → index 25 → 25 - 11 = 14
HIT_FRAMES = [8, 14];
idle_t = 0;
atk_t  = -1;                  // -1 = 没在喷；>= 0 = 正在播攻击段
hit_idx = 0;                  // 本轮已经打了几波（0/1/2）；对应 HIT_FRAMES 的下标
atk_flash_speed = 5;          // 攻击段每帧停留帧数（16 × 5 = 80 帧，最短 cycle 84 也放得完）

image_index = 0;
idle_anim    = 10;            // 父对象推帧要读（实际帧由下面自己推，这里的值只求不冲突）
attack_anim  = 0;
yn_same_tmp  = 0;

// ── 注册表 custom ──
// 同类加成：每张 +10%，上限 2 倍（11 只）—— 固定值，写死
yn_bonus = 0.10;
yn_cap   = 2.0;
yn_atk_mult = 1.0;

// ── 攻击状态 ──
yn_timer = 0;
yn_dmg   = 0;
