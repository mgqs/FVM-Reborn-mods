/// @function ronghehuopen_pass_fire(_bullet, _pit)
/// @desc 融合火盆「过火增幅」——由各子弹自己的 Collision_obj_ronghehuopen 调用（与 obj_brazier 同款做法：
///       引擎负责碰撞，卡片侧不再每帧扫描全部子弹，原来那套 with(obj_bullet_parent) 是全卡顿根源）。
///       语义沿用融合火盆（见 obj_ronghehuopen/Create_0 顶部注释）：
///         普通子弹：burnt 0 → 1，点燃并增幅（damage × 火盆 atk 倍率）；
///         冰弹    ：burnt < 2 才吃 —— 0 → 1 只是「融化」（贴图变普通弹、不再减速、不增幅），1 → 2 才点燃并增幅；
///         2 转（缤纷杂果冰盘）：普通子弹点燃后变冰弹；冰弹本身经过不生效。
/// @param {id} _bullet 子弹实例
/// @param {id} _pit    融合火盆实例（obj_ronghehuopen）
function ronghehuopen_pass_fire(_bullet, _pit) {
	if (!instance_exists(_bullet) || !instance_exists(_pit)) return;
	if (!variable_instance_exists(_bullet, "brazier_list")) return;
	if (!variable_instance_exists(_bullet, "burnt")) return;

	// 与各自 Collision_obj_brazier 一致的「可点燃门禁」
	if (variable_instance_exists(_bullet, "can_burn") && !_bullet.can_burn) return;
	if (variable_instance_exists(_bullet, "kind") && !(_bullet.kind == "fire" || _bullet.kind == "star")) return;
	if (variable_instance_exists(_bullet, "disabled") && _bullet.disabled) return;

	// 同排判定：普通子弹按行，竖排子弹按列（与旧卡片侧扫描同口径，避免跨行误点燃）
	//   星弹（星星兔）没有行/列 —— 它的 row 恒为 0，直接用会「火盆只要在 0 行就全场点燃」，
	//   所以改看 center_row，并且只让水平那一发吃增幅（与 obj_brazier / 火神 / 金牛同口径）
	var _same_line;
	if (variable_instance_exists(_bullet, "kind") && _bullet.kind == "star") {
		_same_line = (abs(_bullet.move_y) < 0.001) && (_bullet.center_row == _pit.grid_row);
	} else {
		_same_line = (variable_instance_exists(_bullet, "row") && _bullet.row == _pit.grid_row)
		          || (variable_instance_exists(_bullet, "col") && _bullet.col == _pit.grid_col);
	}
	if (!_same_line) return;

	// 一颗子弹对同一座火盆只记一次（brazier_list 由子弹 Create 重建，池复用天然复位）
	if (ds_list_find_index(_bullet.brazier_list, _pit.id) != -1) return;

	var _is_ice = (string_count("ice", object_get_name(_bullet.object_index)) != 0);
	if (_pit.shape >= 2 && _is_ice) return;      // 2 转（冰属性）对冰弹不生效

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
		_bullet.damage = round(_bullet.damage * _pit.atk);
		// 焚寂马（kind == "fire"）的分裂冲击波是按 base_damage 生成的，
		// 不同步增幅就会出现「直击被强化、分裂波还是原伤害」的观感（与 obj_brazier / 火神 / 金牛同口径）。
		if (variable_instance_exists(_bullet, "kind") && _bullet.kind == "fire"
			&& variable_instance_exists(_bullet, "base_damage")) {
			_bullet.base_damage = round(_bullet.base_damage * _pit.atk);
		}
		if (_pit.shape >= 2) {
			// 灵魂融合（2 转）：过火子弹变冰弹 —— brazier_list 里插哨兵 -9999 作标记，
			// 贴图锁定 / 命中减速 / 冰冻命中特效 / 碎冰死亡统一交给独立控制器 obj_ronghehuopen_ice_ctrl
			ds_list_add(_bullet.brazier_list, -9999);
			_bullet.sprite_index = spr_ronghehuopen_ice_bullet;
			_bullet.image_xscale = 1.4;
			_bullet.image_yscale = 1.4;
			if (!instance_exists(obj_ronghehuopen_ice_ctrl)) {
				instance_create_depth(0, 0, -10000, obj_ronghehuopen_ice_ctrl);
			}
		}
		else {
			// 点燃表现（与原版火盆一致）：点亮后放大一圈
			_bullet.image_xscale = 1.8;
			_bullet.image_yscale = 1.8;
		}
	}
	ds_list_add(_bullet.brazier_list, _pit.id);
	audio_play_sound(snd_bullet_burnt, 0, 0);
}
