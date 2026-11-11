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

idle_anim   = 12;   // 待机 0~12
attack_anim = 10;   // 攻击 13~23（素材共 24 帧）

attack_timer = 0;
state = CARD_STATE.IDLE;

// ── 可调参数 ──
jg_shot_count  = 1;      // 一轮音波数，下面按形态 / custom["子弹数"] 覆写
jg_burst_left = 0;      // 本轮还没出膛的音波数
jg_burst_timer = 0;
jg_burst_gap = 6;       // 后续音波比上一发晚几帧出膛
jg_art_up = -18;        // 出膛点相对卡片 y 的偏移（音波从头部冒出）
jg_lead = 4;            // 提前几帧摆攻击姿态
jg_fire_delay = 1;      // 提前几帧真正出膛

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

// 卡面写「攻击沿途陆、空鼠军」：pierce 的 hittable 只有 普通/走行/障碍/幽灵，不含 air，这里补上
jg_hittable = get_hittable_enemy_types(target_type);
if (array_get_index(jg_hittable, "air") == -1) array_push(jg_hittable, "air");
