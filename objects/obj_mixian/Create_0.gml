// 米线卡片：连接并净化最近的龙柱，同时以 5*5 范围攻击老鼠
event_inherited();

plant_id = "mixian";
current_level = 1;
obj_type = object_index;
event_user(0);

// 形态对应精灵：0=spr_mixian，1=spr_mixian_1，2=spr_mixian_2
switch (shape) {
    case 1: sprite_index = spr_mixian_1; break;
    case 2: sprite_index = spr_mixian_2; break;
    default: sprite_index = spr_mixian; break;
}
image_speed = 0;
image_index = 0;
flash_speed = 5;

// 动画段（资源帧从 1 开始计数，image_index 从 0 开始）
// 1-8 待机 -> 0-7；9-16 攻击 -> 8-15；17-22 死亡 -> 16-21
mixian_idle_tick = 0;
mixian_attack_timer = 0;      // 0 表示可以出手
mixian_attack_phase = 0;      // 0=待机 1=攻击
mixian_attack_tick = 0;
mixian_attack_hit = false;
mixian_attack_targets = [];

// 反伤（参考瓜皮护罩的一转效果）
bleed_damage = 0;
mixian_prev_hp = hp;

// 龙柱连接
mixian_pillar = noone;
mixian_line = noone;
mixian_ring_self = noone;
mixian_ring_pillar = noone;
mixian_link_broken = false;
mixian_link_retry = 0;

// 龙源关卡「米线桥」接口：连接期间向 longyuan_bridge_lines 注册线段
longyuan_bridge_connected = false;
mixian_bridge_registered = false;
mixian_bridge_line = {};
if (!variable_global_exists("longyuan_bridge_lines")) global.longyuan_bridge_lines = [];

/// 断开时收尾连接线与两处光环
mixian_break_visuals = function() {
	with (obj_mixian_xian) {
		if (owner_card == other.id) {
			link_state = "break";
			anim_tick = 0;
			sprite_index = spr_mixian_disxian;
			image_index = 0;
		}
	}
	with (obj_mixian_ring) {
		if (owner_card == other.id) {
			ring_state = "break";
			anim_tick = 0;
			sprite_index = spr_mixian_disconnect;
			image_index = 0;
		}
	}
};

/// 移除米线桥线段并清除桥接标记
mixian_release_bridge = function() {
	longyuan_bridge_connected = false;
	if (!mixian_bridge_registered) return;
	mixian_bridge_registered = false;
	if (!variable_global_exists("longyuan_bridge_lines")) return;
	for (var _i = array_length(global.longyuan_bridge_lines) - 1; _i >= 0; --_i) {
		if (global.longyuan_bridge_lines[_i].owner == id) array_delete(global.longyuan_bridge_lines, _i, 1);
	}
};

// 死亡
mixian_dying = false;
mixian_death_tick = 0;
