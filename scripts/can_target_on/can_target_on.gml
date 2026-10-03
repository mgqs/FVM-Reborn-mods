function can_target_on(card_target_type,enemy_target_type){
	if enemy_target_type == "normal"{
		if card_target_type != "air_only"{
			return true
		}
	}
	if enemy_target_type == "diver"{
		if card_target_type == "throw" || card_target_type == "track" || card_target_type == "rotate"  || card_target_type == "d_fruit"{
			return true
		}
	}
	if enemy_target_type == "air"{
		if card_target_type == "air" || card_target_type == "track" || card_target_type == "air_only" || card_target_type == "rotate"{
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

function get_hittable_enemy_types(bullet_target_type){
	var _types = [];
	if (bullet_target_type == "all") return ["normal", "diver", "air", "dance", "obstacle", "underground", "invisible"];

	if (bullet_target_type != "air_only") array_push(_types, "normal");
	if (bullet_target_type == "throw" || bullet_target_type == "track" || bullet_target_type == "rotate" || bullet_target_type == "d_fruit") array_push(_types, "diver");
	if (bullet_target_type == "air" || bullet_target_type == "track" || bullet_target_type == "air_only" || bullet_target_type == "rotate") array_push(_types, "air");
	if (bullet_target_type == "pierce" || bullet_target_type == "rotate" || bullet_target_type == "d_fruit") array_push(_types, "dance");
	if (bullet_target_type == "pierce" || bullet_target_type == "normal" || bullet_target_type == "rotate" || bullet_target_type == "d_fruit") array_push(_types, "obstacle");
	if (bullet_target_type == "rotate" || bullet_target_type == "d_fruit") array_push(_types, "underground");
	if (bullet_target_type == "pierce" || bullet_target_type == "rotate" || bullet_target_type == "d_fruit") array_push(_types, "invisible");

	return _types;
}