/// obj_ladder Step
/// 每帧逻辑：
///   1) 反查自己下面的宿主植物（只在还没绑定时查一次）
///   2) 绑定的宿主被铲/被吃/被炸 → 梯子自己消失
/// 注意：位置完全沿用放梯瞬间的坐标（原版表现），不做任何贴合移动。
if (global.is_paused) exit;

// ---- 1) 首次反查宿主 ----
if (!instance_exists(host_plant)) {
	host_plant = noone;
	var _gp = get_grid_position_from_world(x, y);
	var _best = noone;
	var _best_dist = 999999;
	// 同一行、且列在自身格 ±1 范围内的植物中，取离梯子最近的一株
	with (obj_card_parent) {
		if (grid_row == _gp.row) {
			if (abs(grid_col - _gp.col) <= 1) {
				var _d = abs(x - other.x);
				// _best / _best_dist 是 var（函数级作用域），跨 with 共享，必须用裸名访问
				if (_d < _best_dist) {
					_best = id;
					_best_dist = _d;
				}
			}
		}
	}
	host_plant = _best;
}

// ---- 2) 已绑定的宿主没了就自毁（从未绑定成功的梯子不会自毁）----
if (host_plant != noone) {
	if (!instance_exists(host_plant) || host_plant.hp <= 0) {
		instance_destroy();
		exit;
	}
}
