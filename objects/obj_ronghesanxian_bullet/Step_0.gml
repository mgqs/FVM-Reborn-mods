if global.is_paused {
    exit;
}
if burnt == 1{
	sprite_index = spr_fire_bullet
}
timer++;
image_index = (floor(timer / 3)) mod 4;

x += move_speed;

if variable_instance_exists(id, "target_row"){

    var target_y =global.grid_offset_y + global.grid_cell_size_y*target_row;

    var transition_speed = 0.15;
    y = lerp(y, target_y, transition_speed);

	if abs(y - target_y) < 30 {
		row = target_row
	}
}

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
			// 灵魂融合（2 转）穿透：同一只只结算一次，结算过就继续往前飞
			if (pierce_all && ds_list_find_index(hited_enemy, _e.id) != -1) continue;
			if (pierce_all) ds_list_add(hited_enemy, _e.id);

			// 先记下 id 与 depth：结算后这只老鼠可能已被打掉，后面挂燃烧特效还要用
			var _eid = _e.id;
			var _edepth = _e.depth;
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

			// 燃烧 buff：命中后 30% 概率附加，每 1 秒结算 1 次、共 3 次[燃烧伤害]，可叠加
			// 统一交给独立控制器（不存在则现建），卡片被铲掉也继续结算
			if (irandom(99) < burn_chance)
			{
				if (!instance_exists(obj_ronghesanxian_burn_ctrl))
				{
					instance_create_depth(0, 0, -10000, obj_ronghesanxian_burn_ctrl);
				}
				if (instance_exists(_eid))
				{
					with (obj_ronghesanxian_burn_ctrl)
					{
						var _found = false;
						for (var _k = 0; _k < array_length(burn_list); _k++)
						{
							if (burn_list[_k].target == _eid)
							{
								burn_list[_k].ticks += 3;
								burn_list[_k].dmg = other.burn_damage;
								_found = true;
								break;
							}
						}
						if (!_found)
						{
							// 挂身火焰：复用后羿的灼烧贴图（缩放 1.8、上移 35px 贴在老鼠身上）
							var _fx = instance_create_depth(other.x, other.y - 35, _edepth - 1, obj_ronghesanxian_burn_fx);
							_fx.follow = _eid;
							array_push(burn_list, {target: _eid, ticks: 3, dmg: other.burn_damage, fx: _fx});
						}
					}
				}
			}

			// 非穿透弹：命中即销毁（命中特效与基础卡 obj_triplewinerack_bullet 一致）
			if (!pierce_all)
			{
				if (!instance_exists(id)) break;
				if burnt == 0
				{
					var inst = instance_create_depth(x, y, depth, obj_coffeecup_bullet_effect)
					inst.sprite_index = spr_ronghesanxian_bullet_effect
				}
				else if burnt == 1
				{
					var inst = instance_create_depth(x + 25, y, depth, obj_fire_bullet_effect)
					inst.sprite_index = spr_fire_bullet_effect
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
