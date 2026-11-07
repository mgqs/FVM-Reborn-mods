// obj_fangkongmiao（防空喵 / 钢盔防空喵 / 狂暴防空喵）Create 事件
// 专业防空类·纯对空类（2026-11-07 新卡）
//   只打空军（target_type = "air_only"），全屏索敌不限行；二转每轮 2 发（第 2 发隔 12 帧）。
event_inherited();

plant_id = "fangkongmiao";
obj_type = object_index;
event_user(0);

if (shape == 0)      sprite_index = spr_fangkongmiao;
else if (shape == 1) sprite_index = spr_fangkongmiao_1;
else                 sprite_index = spr_fangkongmiao_2;

plant_type   = "normal";
feature_type = "normal";
target_type  = "air_only";
is_slowdown  = false;
image_speed  = 0;
flash_speed  = 5;

attack_timer = 0;
state        = CARD_STATE.IDLE;
pending_shot = 0;      // 二转第二发的倒计时

idle_anim   = 13;   // 待机 1~14（索引 0~13）
attack_anim = 11;    // 攻击 15~25（索引 14~24）：14~18 蓄力、19~21 猫化成弹丸、22~24 猫落回
anim_t      = 0;

// 出弹帧（索引）：第 20 帧 = 猫脱篮变弹丸那一刻。改这里就换出弹时机。
//   🔴 只写 fire_frame 不够，Step 必须判 image_index >= fire_frame（照法师蛇写法），否则永远不出弹。
fire_frame        = 19;
fangkongmiao_fired = false;

// 一转起命中附加减速（走 ice_timer，同冰系）：时长走注册表 custom["减速时间"]（秒），改表即生效
var _sk   = variable_instance_exists(id, "skill") ? skill : 0;
var _info = get_plant_data_with_skill("fangkongmiao", shape, clamp(current_level, 0, 16), _sk);
slow_time = (shape >= 1) ? 3 : 0;
if (_info != undefined && ds_map_exists(_info, "减速时间")) slow_time = _info[? "减速时间"];
slow_frames = round(slow_time * 60);
