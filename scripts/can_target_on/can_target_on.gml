function can_target_on(card_target_type,enemy_target_type){
	// "pierce_air" = 穿透类 + 对空（牛油果飞镖）：空军直接放行，其余按 pierce 同口径走
	// 为什么要单开一个组合：pierce 少了 air（打不到空军）、air 少了 obstacle/invisible/dance（丢穿透），
	// 所以不能简单改成 "air"，那样飞镖就穿不了障碍了
	if (card_target_type == "pierce_air"){
		if (enemy_target_type == "air") return true
		card_target_type = "pierce"
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
	// "pierce_air" = 穿透 + 对空（牛油果飞镖）：pierce 的整套目标再补一个 air
	// 注意这里必须保留 normal —— 对空弹也要能打地面，不能做成只打空
	if (bullet_target_type == "pierce_air") return ["normal", "air", "dance", "obstacle", "invisible"];

	if (bullet_target_type != "air_only") array_push(_types, "normal");
	if (bullet_target_type == "throw" || bullet_target_type == "track") array_push(_types, "diver");
	if (bullet_target_type == "air" || bullet_target_type == "track" || bullet_target_type == "air_only" || bullet_target_type == "rotate" || bullet_target_type == "d_fruit") array_push(_types, "air");
	if (bullet_target_type == "pierce" || bullet_target_type == "rotate" || bullet_target_type == "d_fruit") array_push(_types, "dance");
	if (bullet_target_type == "pierce" || bullet_target_type == "normal" || bullet_target_type == "rotate" || bullet_target_type == "d_fruit") array_push(_types, "obstacle");
	if (bullet_target_type == "rotate" || bullet_target_type == "d_fruit") array_push(_types, "underground");
	if (bullet_target_type == "pierce" || bullet_target_type == "rotate" || bullet_target_type == "d_fruit") array_push(_types, "invisible");

	return _types;
}
