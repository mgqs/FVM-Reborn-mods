/// 金刚马 / 梵音金刚马 / 金刚马神使（jingangma）Create 事件
/// 直射类·穿透追踪：全屏索敌「最远」目标（x 最大），发射追踪穿透音波，
///   一路穿过沿途陆/空/幽灵鼠军；命中后音波不消失，继续直线飞出。
///   0 转 1 发 / 1 转 2 发（+15% 定身 1.5s）/ 2 转 3 发（+秒杀平民鼠）
/// 数值走注册表：子弹数 / 定身概率 / 定身时间 → custom 标量（每个形态各写一份，不进数组）
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
jg_shot_count = 1;       // 一轮音波数，下面按形态 / custom["子弹数"] 覆写
jg_fired      = 0;       // 本轮已出膛的音波数
jg_burst_gap  = 10;      // 连发间隔（帧）：10 帧 × 9px/帧 ≈ 90px ≈ 一个弹身 → 前后两发头尾相接、不叠
jg_burst_timer = 0;      // 距上一发的计时
jg_tail       = false;   // 收尾标记：攻击段到点后继续把 22~24 帧（铃铛放下段）播完再回待机
jg_art_up     = -18;     // 出膛点相对卡片 y 的偏移（音波从头部冒出）
jg_fire_frame = idle_anim + 7;   // 首发绑动画第 18 帧（index 17）＝铃铛晃动段 18~21 开头；之后按 jg_burst_gap 连发

// ── 注册表 custom（每个形态各写标量：子弹数 1/2/3、定身概率 0/15/15）──
var _sk   = variable_instance_exists(id, "skill") ? skill : 0;
var _info = get_plant_data_with_skill("jingangma", shape, clamp(current_level, 0, 16), _sk);

jg_shot_count  = (shape >= 2) ? 3 : ((shape == 1) ? 2 : 1);
if (_info != undefined && ds_map_exists(_info, "子弹数")) jg_shot_count = _info[? "子弹数"];

// 定身：1 转起 15% / 1.5 秒 —— 固定值，写死（不进 custom）
jg_stun_time   = (shape >= 1) ? 1.5 : 0;
jg_stun_chance = (shape >= 1) ? 15  : 0;
jg_stun_frames = round(jg_stun_time * 60);
jg_kill_normal = (shape >= 2);    // 2 转：秒杀平民鼠

// 卡面写「攻击沿途陆、空鼠军」+ 通用「可直接攻击幽灵鼠」
//   2026-11-13 用户报「金刚马能打到非主流」：pierce 列表自带 dance(非主流/高跷) / 障碍 / 钻地，太宽
//   → 这里手写白名单，只打 普通陆鼠 / 空军 / 幽灵鼠
jg_hittable = ["normal", "air", "invisible"];
