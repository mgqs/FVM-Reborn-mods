// obj_xuanzhuan_ronghe（融合旋转咖啡喷壶 · 红温 / 果味 / 觉醒）Create 事件
// 数值全部走注册表（mod_cards_init 三形态各一份），技能（冷却）在 mod_skill_init：
//   攻击力  → atk（xlsx「攻击力」，是**一轮攻击的总伤害**，与旋转圈数无关）
//   冷却    → cooldown（注册表 1500 = 技能表 3000 的一半，即「冷却时间减半」）
//   攻击间隔 → cycle（126 帧 = 2.1 秒）
// 机制（三档叠加，1 转起加「减速 + 击杀碎冰」，2 转范围扩到 5×7）：
//   ① 范围伤害：每轮 126 帧，对范围内每只敌人结算一次 atk（不是子弹，是瞬时判定）
//   ② 范围内有可打敌人才开始计时（没敌人不喷、不空转）
//   ③ 1 转起：命中者 ice_timer = 90（1.5 秒减速），被本卡打死的换碎冰死亡动画
event_inherited();
plant_id = "xuanzhuan_ronghe";
obj_type = object_index;
current_level = 1
event_user(0)
if shape == 0{
	sprite_index = spr_xuanzhuan_ronghe
}
else if shape == 1{
	sprite_index = spr_xuanzhuan_ronghe_1
}
else{
	sprite_index = spr_xuanzhuan_ronghe_2
}

plant_type = "normal";
feature_type = "normal";
target_type = "rotate";       // 同原版旋转喷壶：走 can_hit 判定，能打的都打

// ========== 帧段（0 基索引）==========
//   三套素材都是 36 帧，结构一致（0 转已删掉原先多余的第一帧，与其他两档对齐）：
//     1~11 待机（呼吸）→ 12~14 下蹲蓄力 → 15~36 喷发（两圈）
//   待机 0~10（11 帧），喷发 11~35（25 帧）
//   两波喷发 = 转两圈：帧 15~26（第一圈）+ 27~36（第二圈）
//   **两圈都要播**，每圈在「喷雾铺满一圈」那一帧结算一次伤害（帧 22 / 32，1 基）
//   总伤 = atk 不变，每圈各 atk/2（奇数攻击力时第二圈补差）
SEG_IDLE_LEN = 11;            // 待机：素材帧 1~11
SEG_ATK_FIRST = 11;           // 喷发：素材帧 12（含 12~14 的下蹲蓄力）起，到 36
SEG_ATK_LEN = 25;             // 12~36 共 25 帧
// 结算帧（相对喷发段首帧的偏移，0 基）：素材第 22 / 32 帧 = 两圈各喷满一次
//   22 - 12 = 10、32 - 12 = 20
HIT_FRAMES = [10, 20];

image_speed = 0;              // 引擎自动播放关掉，帧在 Step 末尾自己推
attack_anim = 0;
idle_anim = 0;
flash_speed = 5;              // 待机每帧停留帧数（11 帧 × 5 = 55 帧 ≈ 0.9 秒一轮）
atk_flash_speed = 2;          // 喷发每帧停留帧数（25 帧 × 2 = 50 帧 ≈ 0.83 秒；第 22/32 帧 ≈ 0.33/0.67 秒结算）

idle_t = 0;
atk_t = -1;                   // -1 = 没在喷；>= 0 = 正在播喷发段
hit_idx = 0;                  // 本轮已经打了几圈（0/1/2）；对应 HIT_FRAMES 的下标
atk_timer = 0;
atk_interval = 126;           // 2.1 秒一轮

// ========== 范围（格子矩形）==========
//   0/1 转 5×5 = 左右各 2 列、上下各 2 行
//   2 转 5×7 = 左右各 3 列、上下各 2 行（横 7 列 × 竖 5 行）
range_cols = 2;
range_rows = (shape >= 2) ? 3 : 2;

// ========== 1 转起的附加效果 ==========
slow_frames = 150;            // 减速 2.5 秒（敌人 ice_timer 单位是帧；2026-11-09 从 1.5s 加强）
use_ice = (shape >= 1);       // 减速 + 击杀碎冰
