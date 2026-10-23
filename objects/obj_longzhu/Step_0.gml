/// 龙柱每步：封印态判定 → 动画驱动 → 周期效果
if (global.is_paused) exit;

// 未指定位置时，固定落在「地图正中间的格子」
if (col < 0 || row < 0) {
	col = floor((global.grid_cols - 1) / 2);
	row = floor((global.grid_rows - 1) / 2);
	var _p = get_world_position_from_grid(col, row);
	x = _p.x;
	y = _p.y;
}

// ---------- 封印态判定（消费本步米线上报） ----------
var _now_sealed = longzhu_force_sealed || longzhu_bridge_touch;
if (_now_sealed != longzhu_sealed) {
	longzhu_sealed = _now_sealed;
	longzhu_effect_timer = 0;
	if (_now_sealed) {
		longzhu_clip_set(id, "插入地面", true);
	} else {
		longzhu_clip_set(id, "飞起", true);
		if (longzhu_kind == "huang") longzhu_greedy_flame_clamp();
		// 解封（米线断裂、封印被解除等）时立即清除该柱施加的清醒印记
		longzhu_clear_awake_source(id);
	}
}
longzhu_bridge_touch = false;

// ---------- 动画驱动 ----------
longzhu_timer++;
longzhu_clip_frame(id);

// 非循环动作播完 → 后续动作
if (longzhu_clip_done(id)) {
	switch (longzhu_action) {
		case "出生":     longzhu_clip_set(id, longzhu_sealed ? "地面待机" : "悬浮待机"); longzhu_ready = true; break;
		case "飞起":     longzhu_clip_set(id, "悬浮待机"); longzhu_ready = true; break;
		case "插入地面": longzhu_clip_set(id, "地面待机"); longzhu_ready = true; break;
		case "前摇":     longzhu_clip_set(id, "悬浮施法", true); break;
		case "悬浮施法": longzhu_clip_set(id, "悬浮待机"); break;
		case "地面施法": longzhu_clip_set(id, "地面待机"); break;
	}
}

// ---------- 周期效果 ----------
if (longzhu_ready && longzhu_action == (longzhu_sealed ? "地面待机" : "悬浮待机")) {
	longzhu_effect_timer++;
	if (longzhu_effect_timer >= LONGZHU_INTERVAL) {
		longzhu_effect_timer = 0;
		longzhu_clip_set(id, longzhu_sealed ? "地面施法" : "前摇", true);
		longzhu_apply_effect();
	}
}
