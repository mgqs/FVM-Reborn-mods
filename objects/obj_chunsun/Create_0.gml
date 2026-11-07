event_inherited();
plant_id = "chunsun";
obj_type = object_index;
event_user(0);

// 不占格：可与其他卡叠放（同棉花糖/木盘子），但不能与自己叠放——放置判定见 can_place_at_position 的 gridless 分支
plant_type = "gridless";
feature_type = "normal";

sprite_index = spr_chunsun;
if (shape == 1) sprite_index = spr_chunsun_1;
else if (shape >= 2) sprite_index = spr_chunsun_2;

// 攻击时铺在范围内的「刺」贴图
spike_sprite = spr_chunsun_spike;
if (shape == 1) spike_sprite = spr_chunsun_spike_1;
else if (shape >= 2) spike_sprite = spr_chunsun_spike_2;

image_speed = 0;
flash_speed = 5;

// 帧段（资源第 N 帧 = image_index N-1）：准备 1-14 / 冒芽 15-19 / 待机 20-30
// 资源 31 起下面的云（本体）已消失、只剩笋芽：本体不播这段（攻击时云底座要保留），
// 这段只用来做「刺」精灵 spr_chunsun_spike；攻击表现由范围内每格的刺对象负责
PREPARE_LAST = 13;
GROW_FIRST   = 14;
GROW_LAST    = 18;
IDLE_FIRST   = 19;
IDLE_LAST    = 29;
ATK_BODY_FRAME = 29;    // 攻击相位本体固定显示这一帧（29 = 资源第 30 帧「云底座 + 笋」）
ATK_HOLD_TICKS = 4;     // 攻击相位持续几个动画帧（4 帧 ≈ 0.33 秒）

// 攻击范围：横向左右各 1 格；纵向 3*3 上下各 1 行，二转 3*5 上下各 2 行
range_col = 1;
range_row = (shape >= 2) ? 2 : 1;

// 准备时间 = 注册表 custom["准备时间"]（秒），技能表 register_card_skill("chunsun","准备时间",…)
//   会把它覆盖成 6.5→3.5 秒。cycle 已归还成 0（不再借它存准备时间），这里换算成帧存 prepare_frames。
var _sk   = variable_instance_exists(id, "skill") ? skill : 0;
var _info = get_plant_data_with_skill("chunsun", shape, clamp(current_level, 0, 16), _sk);
prepare_time   = 6.5;   // 秒（兜底 = 技能 0 级）
if (_info != undefined && ds_map_exists(_info, "准备时间")) prepare_time = _info[? "准备时间"];
prepare_frames = round(prepare_time * 60);

max_attack = 5;                                     // 最多攻击 5 次
attack_count = 0;
attack_timer = 0;
// 存在时间写死：0 转 45 秒，一·二转 90 秒（cycle 已归还成 0，不兼这个）
life_time = (shape >= 1) ? 90 * 60 : 45 * 60;
alive_timer = 0;

phase = 0;      // 0=准备 1=冒芽 2=待机 3=攻击
anim_tick = 0;
phase_timer = 0;
swing_done = false;
image_index = 0;
