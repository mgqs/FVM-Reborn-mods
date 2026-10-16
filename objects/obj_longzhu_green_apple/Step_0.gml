/// 青苹果：待机动画 + 周期性为同格老鼠回复体力
if (global.is_paused) exit;

longzhu_life++;
longzhu_heal_timer++;

// ---------- 状态 → 动画 ----------
if (hp <= 0 || longzhu_life >= LONGZHU_GREEN_APPLE_LIFE) {
	if (longzhu_action != "消失") longzhu_clip_set(id, "消失", true);
} else if (longzhu_action == "破损待机") {
	if (hp > max_hp * 0.4) longzhu_clip_set(id, "正常待机");
} else if (longzhu_action == "正常待机") {
	if (hp <= max_hp * 0.4) longzhu_clip_set(id, "破损待机");
}

// ---------- 动画驱动 ----------
longzhu_timer++;
longzhu_clip_frame(id);
if (longzhu_clip_done(id)) {
	switch (longzhu_action) {
		case "出生": longzhu_clip_set(id, "正常待机"); break;
		case "消失": instance_destroy(); exit; break;
	}
}

// ---------- 提升接触老鼠的体力 ----------
if (longzhu_heal_timer >= LONGZHU_GREEN_APPLE_HEAL_INTERVAL) {
	longzhu_heal_timer = 0;
	with (obj_enemy_parent) {
		if (hp > 0 && grid_col == other.col && grid_row == other.row) {
			longzhu_heal_mouse(id, LONGZHU_GREEN_APPLE_HEAL);
		}
	}
}
