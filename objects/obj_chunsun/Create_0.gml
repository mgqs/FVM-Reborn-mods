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

// 准备时间：技能表（秒×60 → 帧），未注册技能时按 6.5 秒
prepare_time = 390;
if (ds_map_exists(global.skill_registry, "chunsun")) {
	var _entry = global.skill_registry[? "chunsun"];
	if (is_array(_entry) && array_length(_entry) >= 2 && is_array(_entry[1])) {
		var _tbl = _entry[1];
		prepare_time = _tbl[clamp(skill, 0, array_length(_tbl) - 1)];
	}
}

max_attack = 5;                                     // 最多攻击 5 次
attack_count = 0;
attack_timer = 0;
life_time = (shape >= 1) ? 90 * 60 : 45 * 60;       // 准备结束后存在时间
alive_timer = 0;

phase = 0;      // 0=准备 1=冒芽 2=待机 3=攻击
anim_tick = 0;
phase_timer = 0;
swing_done = false;
image_index = 0;
