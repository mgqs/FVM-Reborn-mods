/// @function nengliangmiao_pass_fire(_bullet, _nlm)
/// @desc 能量喵过喵增幅——语义照抄火盆过火：一颗子弹只被点燃一次（burnt 门槛 + brazier_list），
///       所以火盆与能量喵互斥，谁先碰到算谁的。普通子弹点燃并增幅（damage × atk/100）；
///       冰弹 0→1 只融化、1→2 才点燃增幅。
/// @param {id} _bullet 子弹实例
/// @param {id} _nlm    能量喵实例（obj_nengliangmiao）
function nengliangmiao_pass_fire(_bullet, _nlm) {
	if (!instance_exists(_bullet) || !instance_exists(_nlm)) return;
	if (!variable_instance_exists(_bullet, "brazier_list")) return;
	if (!variable_instance_exists(_bullet, "burnt")) return;

	// 与各自 Collision_obj_brazier 一致的「可点燃门禁」
	if (variable_instance_exists(_bullet, "can_burn") && !_bullet.can_burn) return;
	if (variable_instance_exists(_bullet, "kind") && !(_bullet.kind == "fire" || _bullet.kind == "star")) return;
	if (variable_instance_exists(_bullet, "disabled") && _bullet.disabled) return;

	// 同排 / 同列判定（与火盆同口径，避免跨行误点燃）
	//   星弹（星星兔）没有行/列 —— 改看 center_row，且只让水平那一发吃
	var _same_line;
	if (variable_instance_exists(_bullet, "kind") && _bullet.kind == "star") {
		_same_line = (abs(_bullet.move_y) < 0.001) && (_bullet.center_row == _nlm.grid_row);
	} else {
		_same_line = (variable_instance_exists(_bullet, "row") && _bullet.row == _nlm.grid_row)
		          || (variable_instance_exists(_bullet, "col") && _bullet.col == _nlm.grid_col);
	}
	if (!_same_line) return;

	// 一颗子弹对同一只能量喵只记一次（brazier_list 由子弹 Create 重建，池复用天然复位）
	if (ds_list_find_index(_bullet.brazier_list, _nlm.id) != -1) return;

	var _is_ice = (string_count("ice", object_get_name(_bullet.object_index)) != 0);
	var _touched = false;
	var _ignite = false;
	if (_is_ice) {
		if (_bullet.burnt < 2) {
			_touched = true;
			_bullet.burnt += 1;
			if (_bullet.burnt == 2) _ignite = true;
		}
	} else if (_bullet.burnt == 0) {
		_touched = true;
		_bullet.burnt += 1;
		_ignite = true;
	}
	if (!_touched) return;

	if (_ignite) {
		var _mult = _nlm.atk / 100;          // atk 存的是「平射倍率 × 100」
		_bullet.damage = round(_bullet.damage * _mult);
		// 焚寂马（kind == "fire"）的分裂冲击波按 base_damage 生成，同步增幅（与火盆同口径）
		if (variable_instance_exists(_bullet, "kind") && _bullet.kind == "fire"
			&& variable_instance_exists(_bullet, "base_damage")) {
			_bullet.base_damage = round(_bullet.base_damage * _mult);
		}
		// 点燃表现（与原版火盆一致）：点亮后放大一圈
		_bullet.image_xscale = 1.8;
		_bullet.image_yscale = 1.8;
	}
	ds_list_add(_bullet.brazier_list, _nlm.id);
	audio_play_sound(snd_bullet_burnt, 0, 0);
}
