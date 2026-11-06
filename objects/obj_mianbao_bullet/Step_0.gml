// obj_mianbao_bullet（融合菠萝面包 2 转 · 灵魂子弹）Step 事件
// 直线平射：每帧前移，按 hittable_types 分桶扫同行的敌人，命中即结算并销毁（不穿透）
if global.is_paused{
	exit
}

// 过火（融合火盆 / 火盆 / 火神 / 金牛 / 能量喵）→ 换火焰弹贴图
// 🔴 原来整段漏了这句：burnt 会涨、damage 会乘，但贴图不变，玩家看着就是「过不了火」。
//    与 obj_xiaolongbao_bullet / obj_corn_shooter_bullet 同款；2 转冰化贴图（spr_ronghehuopen_ice_bullet）不要覆盖。
if (burnt >= 1 && sprite_index != spr_ronghehuopen_ice_bullet){
	sprite_index = spr_fire_bullet;
}

x += move_speed;
if x > 2200 or y > 1200 or x < 0 or y < 0{
	instance_destroy();
	exit;
}

hit_tick++;
if (hit_tick >= global.bullet_hit_interval)
{
	hit_tick = 0;
	if (bullet_enemy_reachable(id) && variable_global_exists("enemy_by_type"))
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
				if (_e.hp > 0 && row == _e.grid_row && precise_bbox_collision(id, _e))
				{
					with (_e)
					{
						audio_play_sound(hit_sound, 0, 0)
						damage_amount = other.damage
						damage_type = other.damage_type
						event_user(0)
					}
					if (instance_exists(id)) instance_destroy()
					exit;
				}
			}
		}
	}
}
