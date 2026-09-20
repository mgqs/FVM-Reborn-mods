if (global.is_paused)
    exit;

x += move_speed;
y -= cvspeed;
cvspeed -= cgravity;
image_angle -= 5;

if (x > 2200 || y > 1200 || x < -200 || y < -200)
    instance_destroy();

if (target_enemy != -4 && (!instance_exists(target_enemy) || target_enemy.hp <= 0))
{
    if (y >= thrower_y)
    {
        instance_create_depth(x, y, depth, obj_iceeggboilerpult_bullet_effect);
        instance_destroy();
    }
}

// 类型过滤碰撞检测
if (!hit_enemy && variable_global_exists("enemy_by_type"))
{
	for (var _t = 0; _t < array_length(hittable_types); _t++)
	{
		var _key = hittable_types[_t];
		if (!variable_struct_exists(global.enemy_by_type, _key)) continue;
		var _list = global.enemy_by_type[$ _key];
		for (var _i = 0; _i < array_length(_list); _i++)
		{
			var _e = _list[_i];
			if (!instance_exists(_e)) continue;
			if (!hit_enemy && _e.hp > 0 && row == _e.grid_row
				&& bbox_right >= _e.bbox_left && bbox_left <= _e.bbox_right
				&& bbox_bottom >= _e.bbox_top && bbox_top <= _e.bbox_bottom)
			{
				with (_e)
				{
					audio_play_sound(snd_egg_bullet, 0, 0);
					damage_amount = other.damage;
					damage_type = other.damage_type;
					event_user(0);

					if (ice_timer < 600)
						ice_timer = 600;
				}

				instance_create_depth(x, y, depth, obj_thor_bullet_effect_1);
				hit_enemy = true;
				hitted_enemy = _e.id;
				instance_destroy();

				var inst;
				if (sprite_index == spr_thor_bullet_2_s)
					inst = instance_create_depth(x, y, depth, obj_thor_bullet_effect_1);
				else if (sprite_index == spr_thor_bullet_3_s)
					instance_create_depth(x, y, depth, obj_thor_bullet_effect_1);
				else
					inst = instance_create_depth(x, y, depth, obj_thor_bullet_effect_1);

				var distance_x = _e.x + global.grid_cell_size_x;
				var flight_time = 30;
				var total_distance_x = distance_x - x;
				var total_distance_y = 300;
				move_speed = total_distance_x / flight_time;
				cgravity = (2 * total_distance_y) / (flight_time * flight_time);
				cvspeed = (total_distance_y - (0 * cgravity * flight_time * flight_time)) / flight_time;
			}
		}
	}
}
