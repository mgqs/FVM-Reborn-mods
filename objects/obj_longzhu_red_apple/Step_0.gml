/// 红苹果：追踪最近的老鼠，命中后造成伤害并消失
if (global.is_paused) exit;

longzhu_life++;

// 目标丢失 → 就近重新索敌
if (!instance_exists(longzhu_target) || longzhu_target.hp <= 0) {
	longzhu_target = longzhu_nearest_enemy(x, y);
}

// 追踪移动 + 命中判定
if (longzhu_action != "消失" && instance_exists(longzhu_target)) {
	var _dir = point_direction(x, y, longzhu_target.x, longzhu_target.y);
	x += lengthdir_x(LONGZHU_RED_APPLE_SPEED, _dir);
	y += lengthdir_y(LONGZHU_RED_APPLE_SPEED, _dir);
	if (point_distance(x, y, longzhu_target.x, longzhu_target.y) <= 26) {
		longzhu_damage_mouse(longzhu_target, damage);
		longzhu_clip_set(id, "消失", true);
	}
}

// 超时自毁
if (longzhu_life >= LONGZHU_RED_APPLE_LIFE && longzhu_action != "消失") {
	longzhu_clip_set(id, "消失", true);
}

// ---------- 动画驱动 ----------
longzhu_timer++;
longzhu_clip_frame(id);
if (longzhu_clip_done(id)) {
	switch (longzhu_action) {
		case "旋转待机": longzhu_clip_set(id, "正常待机"); break;
		case "消失":     instance_destroy(); exit; break;
	}
}
