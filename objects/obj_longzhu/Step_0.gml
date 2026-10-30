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

// ---------- 图层：卡片贴图之上、BOSS 贴图之下 ----------
// 柱身深度按「所在格卡片深度再往前 8」算：同格与上方行的卡片会被柱身遮住，
// 龙渊 BOSS 的绘制深度同步提到 -12（见 obj_ly_boss_parent/Step_0），因此 BOSS 仍压在龙柱之上。
depth = calculate_plant_depth(col, row, "gridless") - 8;

// ---------- 封印态判定（消费本步米线上报） ----------
var _now_sealed = longzhu_force_sealed || longzhu_bridge_touch;
if (_now_sealed != longzhu_sealed) {
	longzhu_sealed = _now_sealed;
	longzhu_effect_timer = 0;
	// 封印状态变化后立即重算火苗上限（全体贪婪龙柱封印 → 15000）
	longzhu_flame_cap_refresh();
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
// 松露大厅（橙）封印期间：3x3 内卡片在「整段封印持续时间」内一直保持清醒。
// 每帧刷新计时器（不播特效），不再依赖 15s 一次的施法 —— 施法刷新会漏掉刚放进范围的卡片，
// 施法被打断时也会断档。解封时仍由 longzhu_clear_awake_source 立即清除印记。
if (longzhu_kind == "cheng" && longzhu_sealed) {
	var _awake_cards = longzhu_cards_in_3x3(col, row);
	for (var _ai = 0; _ai < array_length(_awake_cards); ++_ai) {
		longzhu_awake_touch(_awake_cards[_ai]);
	}
}

// 贪婪（黄）：封印后用独立计时器返还火苗。原实现挂在「地面待机」动画判定下，
// 一旦动画停在插入/施法帧（例如连续被米线刷新、播放被打断）机制就整体停摆。
if (longzhu_ready && longzhu_kind == "huang" && longzhu_sealed) {
	longzhu_greedy_timer++;
	if (longzhu_greedy_timer >= LONGZHU_INTERVAL) {
		longzhu_greedy_timer = 0;
		longzhu_greedy_return_flame(longzhu_cards_in_3x3(col, row));
	}
} else {
	longzhu_greedy_timer = 0;
}

if (longzhu_ready && longzhu_action == (longzhu_sealed ? "地面待机" : "悬浮待机")) {
	longzhu_effect_timer++;
	if (longzhu_effect_timer >= LONGZHU_INTERVAL) {
		longzhu_effect_timer = 0;
		longzhu_clip_set(id, longzhu_sealed ? "地面施法" : "前摇", true);
		longzhu_apply_effect();
	}
}
