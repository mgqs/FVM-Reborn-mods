// obj_rongheshuanggu_bullet_air（融合双菇 · 对空子弹）Step
if global.is_paused {
    exit;
}
timer++;
if burnt == 1{
	sprite_index = spr_fire_bullet
}
image_index = (floor(timer / 3)) mod 4;

if (homing){
	// ===== 2 转：全屏追踪，优先最靠前（x 最小）的空军 =====
	if (target_enemy != -4){
		if (!instance_exists(target_enemy)) target_enemy = -4;
		else if (target_enemy.hp <= 0) target_enemy = -4;
	}
	if (target_enemy == -4){
		var _best = -4;
		with (obj_enemy_parent){
			if (hp > 0 && target_type == "air"){
				if (_best == -4 || x < _best.x) _best = id;
			}
		}
		target_enemy = _best;
	}

	if (target_enemy != -4){
		var _tx = (target_enemy.bbox_left + target_enemy.bbox_right) * 0.5;
		var _ty = (target_enemy.bbox_top + target_enemy.bbox_bottom) * 0.5;
		var _dir = point_direction(x, y, _tx, _ty);
		x += lengthdir_x(move_speed, _dir);
		y += lengthdir_y(move_speed, _dir);
		if (target_enemy.hp > 0 && precise_bbox_collision(id, target_enemy)){
			with (target_enemy){
				if other.burnt == 1 audio_play_sound(snd_fire_hit, 0, 0)
				else audio_play_sound(hit_sound, 0, 0)
				damage_amount = other.damage
				damage_type = other.damage_type
				event_user(0)
			}
			var _fx = instance_create_depth(x, y, depth, obj_rongheshuanggu_effect_air);
			if bullet_shape == 0 _fx.sprite_index = spr_rongheshuanggu_effect_air
			else if bullet_shape == 1 _fx.sprite_index = spr_rongheshuanggu_effect_air_1
			else _fx.sprite_index = spr_rongheshuanggu_effect_air_2
			instance_destroy();
			exit;
		}
	}
	else{
		// 场上没有空军：直着飞出去
		x += move_speed;
	}
}
else{
	// ===== 0/1 转：平射 + 本行命中 =====
	x += move_speed;

	hit_tick++;
	if (hit_tick >= global.bullet_hit_interval)
	{
		hit_tick = 0;
		if (bullet_enemy_reachable(id)) {
	if (variable_global_exists("enemy_by_type"))
	{
		for (var _t = 0; _t < array_length(hittable_types); _t++)
		{
			var _key = hittable_types[_t];
			if (!variable_struct_exists(global.enemy_by_type, _key)) continue;
			var _list = bullet_sap_type_list(id, _key);
			for (var _i = 0; _i < array_length(_list); _i++)
			{
				var _e = _list[_i];
			if (!instance_exists(_e)) continue;
			if (!instance_exists(id)) break;
			if (_e.hp > 0 && row == _e.grid_row
	    && precise_bbox_collision(id, _e))
			{
				with (_e)
				{
					if other.burnt == 1
					{
						audio_play_sound(snd_fire_hit, 0, 0)
					}
					else
					{
						audio_play_sound(hit_sound, 0, 0)
					}
					damage_amount = other.damage
					damage_type = other.damage_type
					event_user(0)
				}

				var _fx = instance_create_depth(x, y, depth, obj_rongheshuanggu_effect_air);
				if bullet_shape == 0{
					_fx.sprite_index = spr_rongheshuanggu_effect_air
				}
				else if bullet_shape == 1{
					_fx.sprite_index = spr_rongheshuanggu_effect_air_1
				}
				else{
					_fx.sprite_index = spr_rongheshuanggu_effect_air_2
				}
				instance_destroy()
				exit;
			}
			}
		}
	}
		}
	}
}

if x > 2200 or y > 1200 or x < 0 or y < 0 {
    instance_destroy();
    exit;
}
