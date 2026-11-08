// obj_huojianzhu（火箭猪 / 运载火箭猪 / 反重力火箭猪）Create 事件
// 追踪类·群轰追踪（2026-11-07 新卡）
//   全屏最近敌人，每轮 2 / 2 / 3 枚追踪导弹，命中 3×3 范围伤害；一转起附加定身。
//   2026-11-08：导弹数改 2/2/3，攻击力表改「每发」口径（总伤害不变）；定身时间走 custom。
event_inherited();

plant_id = "huojianzhu";
obj_type = object_index;
event_user(0);

if (shape == 0)      sprite_index = spr_huojianzhu;
else if (shape == 1) sprite_index = spr_huojianzhu_1;
else                 sprite_index = spr_huojianzhu_2;

plant_type   = "normal";
feature_type = "normal";
target_type  = "track";
is_slowdown  = false;
image_speed  = 0;
flash_speed  = 5;

attack_timer = 0;
state        = CARD_STATE.IDLE;

idle_anim   = 12;   // 待机 1~13
attack_anim = 16;    // 攻击 14~29（索引 13~28）
anim_t      = 0;

// 出弹帧（索引）：用户 2026-11-08 口径「发射应该是第 26 帧」→ 索引 25。
//   🔴 只写 fire_frame 不够，Step 必须判 image_index >= fire_frame（照法师蛇写法）。
fire_frame  = 25;
huojianzhu_fired = false;

// 每轮导弹数：**2 / 2 / 3**（2026-11-08 用户口径，原 1/1/3）
//   攻击力表已同步改成「每发」口径（0 转 = 原值 ÷2、1 转 = 原值 ÷2、2 转 = 原值 ÷3），
//   所以每轮总伤害与改前一致。
shots       = (shape >= 2) ? 3 : 2;

// ── 定身时间：走注册表 custom["定身时间"]（秒），改表即生效 ──
//   0 转不配 → 0（无定身）；1·2 转 = 2 秒。BOSS 由敌人父对象统一免疫。
var _sk   = variable_instance_exists(id, "skill") ? skill : 0;
var _info = get_plant_data_with_skill("huojianzhu", shape, clamp(current_level, 0, 16), _sk);
stun_time = (shape >= 1) ? 2 : 0;
if (_info != undefined && ds_map_exists(_info, "定身时间")) stun_time = _info[? "定身时间"];
stun_frames = round(stun_time * 60);
