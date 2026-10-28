function can_target_on(card_target_type,enemy_target_type){
	// "pierce_air" = 穿透 + 对空（牛油果飞镖）：**只认普通 / 空军 / 障碍**
	//   🔴 不能再转成 "pierce" —— pierce 额外含 dance（非主流、龙王高跷）和 invisible（幽灵鼠），
	//      那两类不吃「穿透」，牛油果飞镖不该顺路打中它们（2026-10-29 用户口径：只有穿透功能）
	if (card_target_type == "pierce_air"){
		return (enemy_target_type == "normal" || enemy_target_type == "air" || enemy_target_type == "obstacle")
	}
	if enemy_target_type == "normal"{
		if card_target_type != "air_only"{
			return true
		}
	}
	if enemy_target_type == "diver"{
		if card_target_type == "throw" || card_target_type == "track"{
			return true
		}
	}
	if enemy_target_type == "air"{
		if card_target_type == "air" || card_target_type == "track" || card_target_type == "air_only" || card_target_type == "rotate" || card_target_type == "d_fruit"{
			return true
		}
	}
	if enemy_target_type == "dance"{
		if card_target_type == "pierce" || card_target_type == "rotate"  || card_target_type == "d_fruit"{
			return true
		}
	}
	if enemy_target_type == "obstacle"{
		if card_target_type == "pierce" || card_target_type == "normal" || card_target_type == "rotate" || card_target_type == "d_fruit"{
			return true
		}
	}
	if enemy_target_type == "underground"{
		if card_target_type == "rotate" || card_target_type == "d_fruit"{
			return true
		}
	}
	if enemy_target_type == "invisible"{
		if card_target_type == "pierce" || card_target_type == "all" || card_target_type == "rotate" || card_target_type == "d_fruit"{
			return true
		}
	}
	if card_target_type == "all"{
		return true
	}
	return false
}

function can_hit(bullet_target_type,enemy_target_type){
	return can_target_on(bullet_target_type,enemy_target_type)
}

/// 是否为钻地状态中的龙渊地精鼠（喷壶类卡片可在索敌与命中阶段放行）
function is_digging_dijing(_inst){
	return instance_exists(_inst)
		&& variable_instance_exists(_inst, "mouse_id") && _inst.mouse_id == "longyuan_dijing"
		&& variable_instance_exists(_inst, "ly_mode") && _inst.ly_mode == "dig";
}

function get_hittable_enemy_types(bullet_target_type){
	var _types = [];
	if (bullet_target_type == "all") return ["normal", "diver", "air", "dance", "obstacle", "underground", "invisible"];
	// "pierce_air" = 穿透 + 对空（牛油果飞镖）：普通 + 空军 + 障碍，**不含 dance / invisible**
	if (bullet_target_type == "pierce_air") return ["normal", "air", "obstacle"];

	if (bullet_target_type != "air_only") array_push(_types, "normal");
	if (bullet_target_type == "throw" || bullet_target_type == "track") array_push(_types, "diver");
	if (bullet_target_type == "air" || bullet_target_type == "track" || bullet_target_type == "air_only" || bullet_target_type == "rotate" || bullet_target_type == "d_fruit") array_push(_types, "air");
	if (bullet_target_type == "pierce" || bullet_target_type == "rotate" || bullet_target_type == "d_fruit") array_push(_types, "dance");
	if (bullet_target_type == "pierce" || bullet_target_type == "normal" || bullet_target_type == "rotate" || bullet_target_type == "d_fruit") array_push(_types, "obstacle");
	if (bullet_target_type == "rotate" || bullet_target_type == "d_fruit") array_push(_types, "underground");
	if (bullet_target_type == "pierce" || bullet_target_type == "rotate" || bullet_target_type == "d_fruit") array_push(_types, "invisible");

	return _types;
}

/// @func can_hit_segment_bbox(x1, y1, x2, y2, inst, pad_x, shrink_y)
/// @desc 线段 (x1,y1)→(x2,y2) 是否穿过实例的碰撞盒
///       pad_x    = 水平方向外扩（容忍横向移动 / 擦边）
///       shrink_y = 垂直方向**内缩**（避免水平弹道正好擦着上下相邻行敌人的脚底 / 头顶被判成命中）
///       用途：多向发射的卡片做**弹道级索敌** —— 判「这几条射线上真的碰得到这只老鼠吗」，
///       比「前方有敌人就开火」的角度阈值准，也不会朝已经越过卡片的目标空放
function can_hit_segment_bbox(_x1, _y1, _x2, _y2, _inst, _pad_x = 0, _shrink_y = 0) {
	if (!instance_exists(_inst)) return false;
	var _l = _inst.bbox_left   - _pad_x;
	var _r = _inst.bbox_right  + _pad_x;
	var _t = _inst.bbox_top    + _shrink_y;
	var _b = _inst.bbox_bottom - _shrink_y;
	if (_t >= _b) return false;
	var _dx = _x2 - _x1;
	var _dy = _y2 - _y1;

	// Liang-Barsky：线段参数 t ∈ [0,1]，两个轴分别求交集
	var _tmin = 0;
	var _tmax = 1;

	if (abs(_dx) < 0.00001) {
		if (_x1 < _l || _x1 > _r) return false;
	} else {
		var _ta = (_l - _x1) / _dx;
		var _tb = (_r - _x1) / _dx;
		_tmin = max(_tmin, min(_ta, _tb));
		_tmax = min(_tmax, max(_ta, _tb));
		if (_tmin > _tmax) return false;
	}

	if (abs(_dy) < 0.00001) {
		if (_y1 < _t || _y1 > _b) return false;
	} else {
		var _ta2 = (_t - _y1) / _dy;
		var _tb2 = (_b - _y1) / _dy;
		_tmin = max(_tmin, min(_ta2, _tb2));
		_tmax = min(_tmax, max(_ta2, _tb2));
		if (_tmin > _tmax) return false;
	}

	return true;
}
