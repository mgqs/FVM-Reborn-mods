/// obj_yeziguo Step
/// 椰子果（碾压型，一次性；同面粉袋）：
///   跳起碾压「前方单格」鼠军 → 落到目标格结算 → 砸满次数后销毁
///   0 转：碾压 / 伤害 / 眩晕都只在落点单格
///   1 转：碾压 / 伤害 / 眩晕都是落点 3*3
///   2 转：同 1 转，但连砸 3 次，每次间隔 1.5 秒；**砸完停在落点格**，
///         落点格即它新的「所在格」（grid_col/row 与 global.grid_plants 占格登记一并搬过去），
///         并以该格为中心 ±2 格（5*5）重新索敌后再次起跳。
///   **砸出去之后就不会中途消失**：后续每次若 5*5 内没有可索敌的敌人，就**原地砸**
///   （落点格 = 自己当前所在格），直到把 `yyz_crush_total` 次数砸满才 `instance_destroy()`。
/// 注：伤害与碾压照常作用于 BOSS，只有**眩晕**对 BOSS 无效（is_boss 为 true 时不施加眩晕）。
if (global.is_paused) exit;

event_inherited();   // 父对象：动画帧推进 / 冻结处理

if (is_frozen) exit;

// 记录「当前所在格」（占格登记用）；之后每次落到新格都会在结算时更新
if (yyz_cell_col == -1) {
	yyz_cell_col = grid_col;
	yyz_cell_row = grid_row;
}

// 星级显示（obj_stars）跟着卡走：它自己只处理「父卡没了自毁」，坐标不会跟随，
// 会移动的卡都得自己同步 —— 与 obj_flour_sack/Step_0.gml:54-57 同一写法。
if (instance_exists(banding_star_obj)) {
	banding_star_obj.x = x;
	banding_star_obj.y = y - 5;
}

// ---------------- 本帧索敌范围 ----------------
var _search = false;
var _c0 = 0;
var _c1 = -1;
var _r0 = 0;
var _r1 = -1;

if (yyz_phase == 0) {
	// 待机：本行「前方 3 格」
	_search = true;
	_c0 = grid_col + 1;  _c1 = grid_col + 3;
	_r0 = grid_row;      _r1 = grid_row;
}
else if (yyz_phase == 2) {
	// 2 转：间隔等待结束 → 以「上一落点格」为中心 5*5 再找目标
	yyz_wait_timer--;
	if (yyz_wait_timer <= 0) {
		_search = true;
		_c0 = yyz_hit_col - 2;  _c1 = yyz_hit_col + 2;
		_r0 = yyz_hit_row - 2;  _r1 = yyz_hit_row + 2;
	}
}

// ---------------- 索敌（范围内取最近的） ----------------
if (_search) {
	var _pick = noone;
	var _best_dist = 999999;
	with (obj_enemy_parent) {
		if (hp > 0
			&& can_target_on(other.target_type, target_type)
			&& grid_col >= _c0 && grid_col <= _c1
			&& grid_row >= _r0 && grid_row <= _r1) {
			var _d = point_distance(x, y, other.x, other.y);
			if (_d < _best_dist) {
				_best_dist = _d;
				_pick = id;
			}
		}
	}

	// 有目标 → 跳到目标格；2 转后续段没目标 → **原地砸**（把剩余次数砸掉，而不是直接消失）
	var _has_target = (_pick != noone);
	var _in_place   = (!_has_target && yyz_phase == 2);

	if (_has_target) {
		yyz_hit_col = _pick.grid_col;
		yyz_hit_row = _pick.grid_row;
	}
	else if (_in_place) {
		yyz_hit_col = yyz_cell_col;   // 原地砸：落点格 = 自己现在所在的格
		yyz_hit_row = yyz_cell_row;
	}

	if (_has_target || _in_place) {
		var _land = get_world_position_from_grid(yyz_hit_col, yyz_hit_row);
		yyz_start_x  = x;
		yyz_start_y  = y;
		yyz_target_x = _land.x;
		yyz_target_y = _land.y;

		if (yyz_phase == 0) yyz_crush_left = yyz_crush_total;
		yyz_phase = 1;
		yyz_has_impact = false;
		state = CARD_STATE.ATTACK;
		flash_speed = 5;
		image_index = idle_anim + 1;
		yyz_last_index = image_index;
	}
}

// ---------------- 攻击中：位移 + 落地结算 + 收招 ----------------
if (yyz_phase == 1) {

	var _jump_from = idle_anim + 1;    // 起跳首帧（14）

	// 起跳段：从起点向落点水平推进（y 不动，跳跃弧线已画在贴图里）
	// 用 !yyz_has_impact 卡住：第 21 帧落地结算后就不再改坐标。
	// 注意：攻击动画播完时父对象会把 image_index 从 27 回卷到 14，若那时还跑 lerp（_t = 0）
	//       会把椰子果瞬间拉回起跳点（表现就是「砸完弹回原格」）。
	if (!yyz_has_impact) {
		var _t = clamp((image_index - _jump_from) / (yyz_impact_frame - _jump_from), 0, 1);
		x = lerp(yyz_start_x, yyz_target_x, _t);
		y = lerp(yyz_start_y, yyz_target_y, _t);
	}

	// ① 落地撞击（第 21 帧）当场结算
	if (!yyz_has_impact && image_index >= yyz_impact_frame) {
		var _crow = yyz_hit_row;
		var _ccol = yyz_hit_col;
		// 0 转：碾压 / 伤害 / 眩晕都只在落点单格；1/2 转：落点 3*3
		var _aoe = (shape >= 1) ? 1 : 0;

		// (1) 落点范围内：一份 [攻击力] 伤害（无视护盾）+ 眩晕 3 秒（BOSS 免晕）
		//     + 不防爆的直接碾压销毁（同面粉袋：秒杀、不生成任何特效）
		with (obj_enemy_parent) {
			if (hp > 0
				&& can_hit(other.target_type, target_type)
				&& abs(grid_row - _crow) <= _aoe
				&& abs(grid_col - _ccol) <= _aoe) {

				damage_amount = other.atk;
				damage_type = "ash";     // 与炸弹类一致：无视护盾
				event_user(0);
				if (!is_boss && stun_timer < other.yyz_stun_time) stun_timer = other.yyz_stun_time;

				// 碾压：只有不防爆（非 BOSS/精英）的才会被秒杀；
				// 防爆鼠只吃上面那一份伤害（此处不再重复扣血）
				if (!immune_to_ash) instance_destroy();
			}
		}

		// (2) 落点格成为它新的「所在格」：把占格登记从旧格搬到落点格
		var _cell_ok = (variable_global_exists("grid_plants")
			&& ds_exists(global.grid_plants, ds_type_grid)
			&& yyz_cell_col >= 0 && yyz_cell_col < global.grid_cols
			&& yyz_cell_row >= 0 && yyz_cell_row < global.grid_rows
			&& _ccol >= 0 && _ccol < global.grid_cols
			&& _crow >= 0 && _crow < global.grid_rows);
		if (_cell_ok && (yyz_cell_col != _ccol || yyz_cell_row != _crow)) {

			var _old_col = yyz_cell_col;
			var _old_row = yyz_cell_row;

			var _old_list = ds_grid_get(global.grid_plants, _old_col, _old_row);
			var _old_idx = ds_list_find_index(_old_list, id);
			if (_old_idx != -1) ds_list_delete(_old_list, _old_idx);

			var _new_list = ds_grid_get(global.grid_plants, _ccol, _crow);
			if (ds_list_find_index(_new_list, id) == -1) ds_list_add(_new_list, id);

			yyz_cell_col = _ccol;
			yyz_cell_row = _crow;
			grid_col = _ccol;
			grid_row = _crow;

			sort_plants_in_grid(_ccol, _crow);
			sort_plants_in_grid(_old_col, _old_row);
			if (variable_global_exists("ocean_buff_dirty")) global.ocean_buff_dirty = true;
		}

		// (3) 声音 + 震屏
		audio_play_sound(snd_flour_sack, 0, false);
		if (global.screen_shake) {
			Camera_Shock(5, 20);
		}

		yyz_has_impact = true;
	}

	// ② 攻击动画播完（父对象把 image_index 从 26 回卷到 14）
	if (image_index < yyz_last_index) {
		yyz_crush_left--;
		if (yyz_crush_left <= 0) {
			// 砸满 yyz_crush_total 次 → 消失（一次性；此刻它停在最后的落点格，占格登记也在那里）
			instance_destroy();
			exit;
		}
		// 还有下一砸：留在落点格等间隔，之后以落点格为中心 5*5 索敌（没目标就原地砸）
		yyz_phase = 2;
		yyz_wait_timer = yyz_crush_interval;
		yyz_has_impact = false;
		state = CARD_STATE.IDLE;
		flash_speed = 6;
		image_index = 0;
	}
}

yyz_last_index = image_index;
