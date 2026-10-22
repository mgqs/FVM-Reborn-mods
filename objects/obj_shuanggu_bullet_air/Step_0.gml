// obj_shuanggu_bullet_air（蚝油双菇 · 对空子弹）Step
if global.is_paused {
    exit;
}
timer++;
if burnt == 1{
	sprite_index = spr_fire_bullet
}
image_index = (floor(timer / 3)) mod 4;

x += move_speed;

if x > 2200 or y > 1200 or x < 0 or y < 0 {
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

			var _fx = instance_create_depth(x, y, depth, obj_shuanggu_effect_air)
			if bullet_shape == 0{
				_fx.sprite_index = spr_shuanggu_effect_air
			}
			else if bullet_shape == 1{
				_fx.sprite_index = spr_shuanggu_effect_air_1
			}
			else{
				_fx.sprite_index = spr_shuanggu_effect_air_2
			}
			instance_destroy()
			exit;
		}
		}
	}
}
	}
}
