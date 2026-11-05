// obj_mianbao_burn_fx（融合菠萝面包 · 5*5 灼烧的单格火格）Step 事件
if (global.is_paused){
	exit
}

t++;

// ---------- 动画：淡入 → 循环 → 淡出（照火龙果 obj_burn_effect 的节奏）----------
if (t <= FADE_IN_FRAMES){
	// 帧 1~4 淡入
	image_index = min(FADE_IN_LAST, floor((t - 1) / FADE_IN_STEP));
}
else if (t <= life){
	// 帧 5~12 循环（每帧停 LOOP_STEP 帧，不再一帧一闪）
	image_index = LOOP_FIRST + (floor((t - FADE_IN_FRAMES - 1) / LOOP_STEP) mod LOOP_LEN);
}
else{
	// 帧 13~16 淡出，播完销毁
	var _k = floor((t - life - 1) / FADE_OUT_STEP);
	if (_k >= FADE_OUT_LEN){
		instance_destroy();
		exit
	}
	image_index = FADE_OUT_FIRST + _k;
}

// ---------- 伤害：每 tick_interval 帧一跳（第 1 帧就结算第一跳，2 秒共 5 跳）----------
if (t <= life && ((t - 1) mod tick_interval) == 0 && variable_global_exists("enemy_by_type")){
	for (var _i = 0; _i < array_length(hittable_types); _i++){
		var _key = hittable_types[_i];
		if (!variable_struct_exists(global.enemy_by_type, _key)) continue;
		var _list = global.enemy_by_type[$ _key];
		for (var _j = 0; _j < array_length(_list); _j++){
			var _e = _list[_j];
			if (!instance_exists(_e) || _e.hp <= 0) continue;
			if (is_digging_dijing(_e)) continue;
			// 只烧「就是这一格」的敌人（老鼠贴图很高，用 bbox 会连带烧到上下行）
			if (_e.grid_col != grid_col || _e.grid_row != grid_row) continue;

			with (_e){
				if (object_index == obj_enemy_parent || object_is_ancestor(object_index, obj_enemy_parent)){
					damage_amount = other.damage;
					damage_type = other.damage_type;
					event_user(0);
				}
				else{
					hp -= other.damage;
				}

				if (hp <= 0){
					instance_create_depth(x, y - 20, depth, obj_mouse_ash_death);
					instance_destroy();
				}
			}
		}
	}
}
