if global.is_paused{
	image_speed = 0
	exit

}
image_speed = 1
if burnt == 1{
	sprite_index = spr_fire_bullet
}
x += move_speed
y += y_move_speed

hit_tick++;
if (hit_tick >= hit_interval)
{
	hit_tick = 0;

	if (variable_global_exists("enemy_by_type") && precise_bbox_prepare(id)
		&& bullet_enemy_reachable(id))
	{
		var _al = global._pbc_l;
		var _ar = global._pbc_r;
		var _at = global._pbc_t;
		var _aq = global._pbc_b;

		var _hit_e = noone;
		var _type_count = array_length(hittable_types);

		for (var _t = 0; _t < _type_count && _hit_e == noone; _t++)
		{
			var _key = hittable_types[_t];
			if (!variable_struct_exists(global.enemy_by_type, _key)) continue;
			var _list = bullet_sap_type_list(id, _key);
			var _n = array_length(_list);
			for (var _i = 0; _i < _n; _i++)
			{
				var _e = _list[_i];
				if (!instance_exists(_e)) continue;
				if (_e.hp <= 0) continue;
				if (!(b_type == 0 || (b_type == 1 && row == _e.grid_row))) continue;
				if (_e.bbox_right < _al || _e.bbox_left > _ar || _e.bbox_bottom < _at || _e.bbox_top > _aq) continue;
				_hit_e = _e;
				break;
			}
		}

		if (_hit_e != noone)
		{
			with (_hit_e)
			{
				if other.burnt == 1{
					audio_play_sound(snd_fire_hit,0,0)
				}
				else{
					audio_play_sound(hit_sound,0,0)
				}
				damage_amount = other.damage
				damage_type = other.damage_type
				event_user(0)
			}
			if burnt != 0{
				var inst = instance_create_depth(x+25,y,depth,obj_fire_bullet_effect)
				inst.sprite_index = spr_fire_bullet_effect
			}
			instance_destroy()
			exit
		}
	}
}

// ===== 出界销毁 =====
// 2026-11-07：原来写死 x>2200 / y>1200 / x<0 / y<-200 —— 战斗区实际只有 x≈695~1765 / y≈228~900，
//   右侧与斜向两发（move_speed=5）要在商店货架、边框上白飞 250+ 帧才销毁，
//   期间每 3 帧还要跑一次 bullet_sap_type_list 候选查询 + 每帧绘制 → 同场子弹堆积就卡。
//   现在与融合海星 / 猪猪料理机刀片统一：边界 = 战斗区外放一格。
//   · 右边界 +1 格：出图那一列（grid_cols + 1）刚刷出来、还没进场的老鼠仍打得到
//   · 上边界 -1 格：上向弹出弹口本身就在卡外（y-95），严格贴边会一出生就被删
//   · 左边界放宽到「老鼠判输线」(grid_offset_x - 150)，老鼠能一路走到那儿
var _bx_l = global.grid_offset_x - 150
var _bx_r = global.grid_offset_x + global.grid_cols * global.grid_cell_size_x + global.grid_cell_size_x
// 2026-11-07：右边界改成「跟着最右的那只老鼠走」。
//   出怪列 = (9 + x_offset)（obj_battle/Create_0：同一行连刷会排到第 11、12 列），
//   原来写死「地图右沿 +1 格」→ 那些在场外排队、还没进场的老鼠永远打不到。
if (variable_global_exists("enemy_max_right")) _bx_r = max(_bx_r, global.enemy_max_right + global.grid_cell_size_x)
var _bx_t = global.grid_offset_y - global.grid_cell_size_y
var _bx_b = global.grid_offset_y + global.grid_rows * global.grid_cell_size_y + global.grid_cell_size_y
if (x < _bx_l || x > _bx_r || y < _bx_t || y > _bx_b){
	instance_destroy()
}
