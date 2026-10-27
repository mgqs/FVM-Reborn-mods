/// 青苹果：待机动画 + 接触老鼠立即被吃掉（为其恢复 1w 体力）
if (global.is_paused) exit;

longzhu_life++;

// 目标接口同步：卡片子弹按 grid_row / grid_col 判定命中，必须每步跟随 col / row
grid_col = col;
grid_row = row;
if (longzhu_hit_flash > 0) longzhu_hit_flash--;

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

// ---------- 老鼠接触立即吃掉：恢复 1w 体力，苹果消失 ----------
if (hp > 0 && longzhu_action != "消失") {
	var _eater = noone;
	with (obj_enemy_parent) {
		if (_eater != noone) break;
		if (hp > 0 && grid_col == other.col && grid_row == other.row) {
			_eater = id;
		}
	}
	if (_eater != noone) {
		longzhu_heal_mouse(_eater, LONGZHU_GREEN_APPLE_HEAL);
		hp = 0; // 触发上方的「消失」动画分支
	}
}
