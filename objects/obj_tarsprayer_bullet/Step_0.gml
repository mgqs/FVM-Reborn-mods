if global.is_paused{
	exit
}
// ── 2026-11-20：碰撞蒙版必须每帧与视觉尺寸对齐 ─────────────────────────
// obj_bullet_parent/BeginStep_0:8-15 每帧先把 image_xscale/yscale 抄进 visual_scale_*，
// 再把 image_xscale/yscale **无条件夹回 1**；而 precise_bbox_collision 是拿
// image_xscale/image_yscale 算 bbox 的 —— 于是「画出来是 1.8 倍的水柱、判定框还是原尺寸」。
// 潜水鼠出图啃植物时身体整体上浮（spr_diver_mouse_up 判定盒顶只到原点上方 75px，
// 普通鼠大多 100px 以上），正好从缩水的判定框上沿擦过去，表现为「能索敌、打不到」。
// 必须在自己的 Step 里每帧重设（同 obj_yuansushe_bullet，见 MISTAKES.md B20）。
image_xscale = 1.8;
image_yscale = 1.8;
x += move_speed
timer++
if timer <= 4* 3 - 1{
	image_index = floor(timer/3) mod 4
}
else{
	if burnt{
		image_index = floor(timer/5) mod 5
	}
	else{
		image_index = floor(timer/5) mod 5 + 4
	}
}
col = get_grid_position_from_world(x,y).col
if ((col >= start_col + 5)&& shape == 0 )||(col >= start_col + 7){
	disabled = true
}
if disabled{
	image_alpha -= 0.1
	if image_alpha <= 0{
		instance_destroy()
		exit
	}
}

if x > 2200 or y > 1200 or x < 0 or y < 0{
	instance_destroy()
	exit
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
			if (!ds_exists(hitted_enemy, ds_type_list)) exit;
			// 命中几何：先走精确 bbox；不中再看「同行纵向容差」。
			// 焦油喷壶是一整条横贯本行的水柱，画面上只要盖住这只鼠就该判定命中；
			// 而 row == _e.grid_row 已经把别的行挡在外面，放宽纵向不会串行。
			// 潜水鼠 / 深海鼠这类「出图啃植物」时原点会整体偏出本行，光靠 bbox 会漏。
			var _geo_hit = precise_bbox_collision(id, _e);
			if (!_geo_hit) {
				_geo_hit = !(bbox_right < _e.bbox_left || bbox_left > _e.bbox_right)
					&& abs(_e.y - y) <= global.grid_cell_size_y;
			}
			if (ds_list_find_index(hitted_enemy, _e.id) == -1 && !disabled
				&& _e.hp > 0 && row == _e.grid_row
    && _geo_hit)
			{
				with (_e)
				{
					audio_play_sound(hit_sound, 0, 0)
					damage_amount = other.damage
					damage_type = other.damage_type
					event_user(0)
				}
				if (ds_exists(hitted_enemy, ds_type_list))
				{
					ds_list_add(hitted_enemy, _e.id)
				}
			}
		}
	}
}
	}
}
