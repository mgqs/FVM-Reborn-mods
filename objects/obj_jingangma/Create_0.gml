/// 金刚马 / 梵音金刚马 / 金刚马神使（jingangma）Create 事件
/// 直射类·穿透追踪：全屏索敌「最远」目标（x 最大），发射追踪穿透音波，
///   一路穿过沿途陆/空/幽灵鼠军；命中后音波不消失，继续直线飞出。
///   原版 1/2/3 发已压成**每轮 1 发**（伤害写进 atk 表 = 官方每发 × 原版发数）
/// 数值走注册表：atk（已含原版发数倍数）；定身 / 秒杀按形态写死，不进 custom
event_inherited();

plant_id = "jingangma";
obj_type = object_index;
event_user(0);

if (shape == 0)      sprite_index = spr_jingangma;
else if (shape == 1) sprite_index = spr_jingangma_1;
else                 sprite_index = spr_jingangma_2;

plant_type   = "normal";
feature_type = "normal";
target_type  = "pierce";       // 穿透：可打 dance / invisible / 障碍 / 钻地
is_slowdown  = false;
attack_type  = ATTACK_TYPE.SHOOTER;
image_speed  = 0;              // 帧由父对象 timer 推，image_speed 必须 0
flash_speed  = 5;

// 2026-11-12 用户口径：待机 = 第 1~11 帧（index 0~10），攻击 = 第 12~24 帧（index 11~23，13 帧）
idle_anim   = 10;
attack_anim = 13;

attack_timer = 0;
state = CARD_STATE.IDLE;

// ── 可调参数 ──
jg_fired      = false;   // 本轮已出膛（压缩后每轮恒 1 发）
jg_tail       = false;   // 收尾标记：攻击段到点后继续把 22~24 帧（铃铛放下段）播完再回待机
jg_art_up     = -18;     // 出膛点相对卡片 y 的偏移（音波从头部冒出）
jg_fire_frame = idle_anim + 7;   // 出弹绑动画第 18 帧（index 17）＝铃铛晃动段 18~21 开头

// 定身：1 转起 15% / 1.5 秒 —— 固定值，写死（不进 custom）
jg_stun_time   = (shape >= 1) ? 1.5 : 0;
jg_stun_chance = (shape >= 1) ? 15  : 0;
jg_stun_frames = round(jg_stun_time * 60);
jg_kill_normal = (shape >= 2);    // 2 转：秒杀平民鼠

// 卡面写「攻击沿途陆、空鼠军」+ 通用「可直接攻击幽灵鼠」
//   2026-11-13 用户报「金刚马能打到非主流」：pierce 列表自带 dance(非主流/高跷) / 障碍 / 钻地，太宽
//   → 这里手写白名单，只打 普通陆鼠 / 空军 / 幽灵鼠
jg_hittable = ["normal", "air", "invisible"];
