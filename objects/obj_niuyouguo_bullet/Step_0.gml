// obj_niuyouguo_bullet（牛油果飞镖）Step 事件
if global.is_paused{
	exit
}

timer++;
// 6 帧自转循环（素材第 7 帧与第 1 帧相同，循环只走 0~5）
image_index = (floor(timer / 2)) mod 6;

x += lengthdir_x(move_speed, travel_dir);
y += lengthdir_y(move_speed, travel_dir);

if (timer > life || x > 2200 || x < -200 || y > 1400 || y < -200){
	instance_destroy();
	exit;
}

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
					if (_e.hp > 0 && precise_bbox_collision(id, _e))
					{
						// 穿透弹：同一只只结算一次，结算过就继续往前飞
						if (ds_list_find_index(hited_enemy, _e.id) != -1) continue;
						ds_list_add(hited_enemy, _e.id);

						with (_e)
						{
							audio_play_sound(hit_sound, 0, 0);
							damage_amount = other.damage
							damage_type = other.damage_type
							// 一转起命中附加减速 1.5 秒（slow_timer = 90 帧，本体为 0）
							if (other.slow_timer > 0)
							{
								ice_timer = max(ice_timer, other.slow_timer);
							}
							event_user(0)
						}
					}
				}
			}
		}
	}
}
