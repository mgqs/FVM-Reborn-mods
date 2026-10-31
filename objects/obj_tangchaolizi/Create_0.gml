// obj_tangchaolizi（糖炒栗子）Create 事件
// 三形态：0 糖炒栗子 / 1 开口笑栗子 / 2 焦香烤栗子（投掷类 · 灼烧投手 · 攻击型）
// 素材：三形态都是 27 帧（103×81 / 115×95 / 129×114）
//      待机 0~11（12 帧一循环，第 13 帧与第 1 帧同像素）；挥锅 18~26（第 21 帧甩出栗子）
// 数值取自「食神谱金卡融合卡前置补全\基本信息.xlsx」291~297 行 + 「米苏.jpg」卡面。
// 机制：向前方喷出可以持续灼烧老鼠的滚烫栗子；落地后 3×3 灼烧 10 跳 × 0.2s，每跳 = 攻击力。
//       **0 转范围 = 3×3 十字**（同排 ±1 格 / 上下同列），**1、2 转 = 3×3 全格**（一转能力：范围扩大）。
event_inherited();
plant_id = "tangchaolizi";
obj_type = object_index;
current_level = 1;
event_user(0);

if (shape == 0) sprite_index = spr_tangchaolizi;
else if (shape == 1) sprite_index = spr_tangchaolizi_1;
else sprite_index = spr_tangchaolizi_2;

idle_anim = 11;              // 0~11 循环（第 12 帧与第 1 帧同像素，别再往后播）
attack_anim = 9;             // 18~26（第 21 帧锅翻到最大、栗子脱手）
flash_speed = 5;             // 同生煎锅
plant_type = "normal";
feature_type = "normal";
is_slowdown = false;
attack_type = ATTACK_TYPE.SHOOTER;
target_type = "throw";
state = CARD_STATE.IDLE;

// 本次挥锅是否已经出弹 / 动画计时
tc_fired = false;
tc_anim_t = 0;
// 本次攻击的落点目标（Other_11 取它的坐标）
tc_target = noone;

// 落地直接进挥锅（attack_anim 9 帧 × flash 5 = 45 步，和 Step 里的窗口算法对齐）
attack_timer = cycle - 45;
