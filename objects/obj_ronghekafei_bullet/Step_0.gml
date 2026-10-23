// obj_ronghekafei_bullet（融合咖啡杯子弹）Step 事件
// 0~3 出膛喷溅：在炮口原地快速播 8 帧（每帧 2 tick），这段不位移
// 4~6 飞行：三帧循环（每帧 5 tick），只有这一段位移
if global.is_paused{
	exit
}

if (phase == 0){
	image_index = min(3, floor(phase_timer / 2))
	phase_timer++
	if (phase_timer >= 8){
		phase = 1
		phase_timer = 0
	}
}
else{
	image_index = 4 + (floor(phase_timer / 5) mod 3)
	phase_timer++
	x += move_speed

	timer++
	if (timer > life){
		instance_destroy()
		exit
	}
}

hit_tick++
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
					if (_e.hp <= 0) continue;
					if (row != _e.grid_row) continue;
					if (!precise_bbox_collision(id, _e)) continue;
					if (pierce_all && ds_list_find_index(hited_enemy, _e) >= 0) continue;

					_e.damage_amount = damage
					_e.damage_type = damage_type
					with (_e)
					{
						audio_play_sound(hit_sound,0,0)
						event_user(0)
					}
					if (pierce_all){
						ds_list_add(hited_enemy, _e)
					}
					else{
						instance_create_depth(x, y, depth, obj_coffeecup_bullet_effect)
						instance_destroy()
						exit
					}
				}
			}
		}
	}
}

if x > 2200 or y > 1200 or x < 0 or y < 0{
	instance_destroy()
	exit
}
