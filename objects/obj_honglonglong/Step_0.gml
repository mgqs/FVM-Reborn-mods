if global.is_paused{
	exit
}

// Register to global enemy type registry
if (!enemy_registered || enemy_registered_type != target_type) {
	if (enemy_registered) {
		var _old_list = global.enemy_by_type[$ enemy_registered_type];
		var _old_idx = array_get_index(_old_list, id);
		if (_old_idx != -1) array_delete(_old_list, _old_idx, 1);
	}
	if (!variable_global_exists("enemy_by_type")) {
		global.enemy_by_type = {};
	}
	var _reg_key = target_type;
	if (!variable_struct_exists(global.enemy_by_type, _reg_key)) {
		global.enemy_by_type[$ _reg_key] = [];
	}
	array_push(global.enemy_by_type[$ _reg_key], id);
	enemy_registered = true;
	enemy_registered_type = target_type;
}

if flash_value > 0 {
	flash_value -= 10
}

// 死亡处理
if (hp <= 0 && state != BOSS_STATE.DEATH) {
	global.save_data.player.gold += 750
    timer = 0;
    state = BOSS_STATE.DEATH;
    target_plant = noone;  // 清除攻击目标
	with obj_battle{
		if boss_count <= 1 && current_wave >= total_wave - 1{
			timer_pause = true
		}
	}
}

switch state{
	case BOSS_STATE.IDLE:
		target_type = "normal"
		sprite_index = spr_honglonglong_idle
		if hp > maxhp * hurt_rate{
			image_index = 0
		}
		else{
			image_index = 1
		}
		if timer >= wait_time{
			timer = 0
			state = BOSS_STATE.LAUNCH
			wait_time = 300
		}
		break
		
	case BOSS_STATE.APPEAR:
		target_type = "normal"
		sprite_index = spr_honglonglong_appear
		
		image_index = floor(timer/5) mod 11
		
		if timer == 11 * 5 - 1{
			timer = 0
			state = BOSS_STATE.IDLE
			break
		}
		break
	
	case BOSS_STATE.SKILL2:
		target_type = "normal"
		sprite_index = spr_honglonglong_skill_2
		if timer < 480{
			if hp > maxhp * hurt_rate{
				image_index = floor(timer/5) mod 16
			}
			else{
				image_index = floor(timer/5) mod 16 + 17
			}
		}
		else{
			if hp > maxhp * hurt_rate{
				image_index = 16
			}
			else{
				image_index = 33
			}
		}
		
		if timer == 480{
			// 变异版激光：0° 与 ±45° 三向齐射，光束绕枪口旋转（精灵原点在光束右端）
			var _muzzle_x = x - 150
			var _muzzle_y = y - 120
			var _beam_angles = [0, 45, -45]
			for (var _bi = 0; _bi < array_length(_beam_angles); _bi++){
				var _laser = instance_create_depth(_muzzle_x, _muzzle_y, -800, obj_honglonglong_laser)
				_laser.laser_angle = _beam_angles[_bi]
			}
			
			// ---------- 毁伤范围：与光束显示路径逐像素对齐 ----------
			// 老写法按「格坐标 1 列 = 1 行」硬走对角，但格子是 107(宽) × 116(高) 的矩形：
			//   精灵绕枪口转 45°，屏幕上每推进 1 列只升降 107px = 107/116 ≈ 0.92 行，
			//   而硬走对角是每列整 1 行，等效斜率 atan2(116,107) ≈ 47.3°，比显示的 45° 更陡。
			//   → 越到末端偏差越大：向左上发射时毁伤偏到上一格、向左下发射时偏到下一格
			//     （两个方向误差镜像对称，正是 m00163 反馈的现象）。
			// 现在改法：
			//   ① 水平束不受影响，仍沿用「BOSS 所在行向左贯穿」的原判定；
			//   ② 斜向束沿枪口出发的真实 45° 屏幕射线逐点采样，横向再覆盖光束厚度，
			//      命中格与红色光带完全重合。
			laser_hit_cells = {}
			
			// ① 水平束：BOSS 所在行，向左贯穿到边界
			for (var _s = 1; _s <= global.grid_cols; _s++){
				var _hcol = grid_col - _s
				if (_hcol < 0) break
				laser_hit_cells[$ string(_hcol) + "," + string(grid_row)] = true
			}
			
			// ② 斜向束：spr_honglonglong_laser 498×42（可见区 top 9 ~ bottom 36，即 27px 厚），
			//    image_xscale/yscale = 1.8，精灵默认朝左（GM 方向 180°），
			//    image_angle 是逆时针（与 GM direction 同向），故实际指向 180° + laser_angle
			//    （45 → 左下 225°，-45 → 左上 135°）
			var _beam_len = 498 * 1.8
			var _beam_half = 27 * 1.8 * 0.5   // 光带半宽 = 贴图可见厚度(bbox top9~bottom36)的一半
			var _sample_step = 4              // 沿光束方向每 4px 采样一次
			var _wide_step = 6                // 沿法线每 6px 采样一次（覆盖光带厚度）
			for (var _ai = 1; _ai < array_length(_beam_angles); _ai++){
				var _dir = 180 + _beam_angles[_ai]
				var _ux = lengthdir_x(1, _dir)
				var _uy = lengthdir_y(1, _dir)
				// 光束法线，用来覆盖光带宽度（±半宽各一条采样线）
				var _nx = lengthdir_x(1, _dir + 90)
				var _ny = lengthdir_y(1, _dir + 90)
				for (var _t = 0; _t <= _beam_len; _t += _sample_step){
					for (var _w = -_beam_half; _w <= _beam_half; _w += _wide_step){
						var _px = _muzzle_x + _ux * _t + _nx * _w
						var _py = _muzzle_y + _uy * _t + _ny * _w
						var _pc = floor((_px - global.grid_offset_x) / global.grid_cell_size_x)
						var _pr = floor((_py - global.grid_offset_y) / global.grid_cell_size_y)
						if (_pc < 0 || _pc >= global.grid_cols || _pr < 0 || _pr >= global.grid_rows) continue
						laser_hit_cells[$ string(_pc) + "," + string(_pr)] = true
					}
				}
			}
			
			with obj_card_parent{
				var _key = string(grid_col) + "," + string(grid_row)
				if (other.laser_hit_cells[$ _key] && plant_id != "player" && plant_type != "lilypad"){
					if hp >= max_hp{
						obj_task_manager.card_loss++
					}
					instance_destroy()
				}
			}
			
		}
		if timer == 510{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
		
	case BOSS_STATE.SKILL1:
		target_type = "normal"
		sprite_index = spr_honglonglong_skill_1
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 16
		}
		else{
			image_index = floor(timer/5) mod 15 + 16
		}
		
		// 变异版导弹技能：对后排发射3枚十字爆炸导弹
		// 智能瞄准：同一行从左到右依次瞄准有卡片的格子
		if timer == 19{
			// 找出所有有卡片的行
			var _rows_with_cards = ds_list_create()
			for(var _r = 0; _r < global.grid_rows; _r++){
				var _has_card = false
				for(var _c = 0; _c < global.grid_cols; _c++){
					var _plant_list = ds_grid_get(global.grid_plants, _c, _r)
					if ds_list_size(_plant_list) > 0{
						_has_card = true
						break
					}
				}
				if _has_card{
					ds_list_add(_rows_with_cards, _r)
				}
			}
			
			// 随机选一行
			var _target_row = -1
			if ds_list_size(_rows_with_cards) > 0{
				_target_row = ds_list_find_value(_rows_with_cards, irandom_range(0, ds_list_size(_rows_with_cards)-1))
			}
			ds_list_destroy(_rows_with_cards)
			
			// 收集该行从左到右有卡片的列（后排优先，即从左到右）
			if _target_row >= 0{
				ds_list_clear(avaliable_pos)
				for(var _c = 0; _c < global.grid_cols; _c++){
					var _plant_list = ds_grid_get(global.grid_plants, _c, _target_row)
					if ds_list_size(_plant_list) > 0{
						ds_list_add(avaliable_pos, {"col":_c, "row":_target_row})
					}
				}
			}
		}
		
		// 发射3枚导弹，间隔一定时间
		var _missile_count = ds_list_size(avaliable_pos)
		if _missile_count > 0{
			if timer == 4*5 && _missile_count >= 1{
				var _p1 = ds_list_find_value(avaliable_pos, 0)
				var _m1 = instance_create_depth(x-60, y-180, -800, obj_honglonglong_missile)
				_m1.target_col = _p1.col
				_m1.target_row = _p1.row
			}
			if timer == 7*5 && _missile_count >= 2{
				var _p2 = ds_list_find_value(avaliable_pos, 1)
				var _m2 = instance_create_depth(x-60, y-180, -800, obj_honglonglong_missile)
				_m2.target_col = _p2.col
				_m2.target_row = _p2.row
			}
			if timer == 10*5 && _missile_count >= 3{
				var _p3 = ds_list_find_value(avaliable_pos, 2)
				var _m3 = instance_create_depth(x-60, y-180, -800, obj_honglonglong_missile)
				_m3.target_col = _p3.col
				_m3.target_row = _p3.row
			}
		}
		
		if timer == 16 * 5 - 1{
			ds_list_destroy(avaliable_pos)
			avaliable_pos = ds_list_create()
			timer = 0
			state = BOSS_STATE.IDLE
			jump_times += 1
		}
		break
		
	case BOSS_STATE.DISAPPEAR:
		sprite_index = spr_honglonglong_idle
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 9
		}
		else{
			image_index = floor(timer/5) mod 9 + 9
		}
		if timer == 9 * 5 - 1{
			image_alpha = 0
		}
		if timer == 210{
			var enemy_row = irandom_range(0,global.grid_rows-1)
			var enemy_pos = get_world_position_from_grid(10,enemy_row)
			x = enemy_pos.x - 50
			y = enemy_pos.y + 30
			image_alpha = 1
			var shape_i = irandom_range(1,100)
			timer = 0
			state = BOSS_STATE.APPEAR
			break
		}
		break
	case BOSS_STATE.SKILL3:
		target_type = "normal"
		sprite_index = spr_honglonglong_skill_3
		
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 24
		}
		else{
			image_index = floor(timer/5) mod 24 + 24
		}
			if timer == 14 * 5{
				// 变异版坐压：以角色模型当前位置为中心摧毁 4x4 范围
				// 判定框整体相对模型向左上偏移一格，与坐压贴图的落点对齐
				var _model_grid = get_grid_position_from_world(x, y)
				var _center_row = _model_grid.row
				var _center_col = _model_grid.col
				var _cards_to_destroy = []
				with obj_card_parent{
					if grid_row >= _center_row - 2 && grid_row <= _center_row + 1
					&& grid_col >= _center_col - 2 && grid_col <= _center_col + 1
					&& !invincible && plant_id != "player"{
						array_push(_cards_to_destroy, id)
					}
				}
				for (var i = 0; i < array_length(_cards_to_destroy); i++){
					var _card = _cards_to_destroy[i]
					with _card{
						if hp >= max_hp{
							obj_task_manager.card_loss++
						}
					}
					instance_destroy(_card)
				}
			}
		// 第 15 帧（floor(timer/5) == 15）落地瞬间播技能特效
		if timer == 15 * 5{
			instance_create_depth(x, y, depth - 1, obj_honglonglong_skill_3_effect)
		}
		if timer >= 24*5-1{
			timer = 0
			state = BOSS_STATE.IDLE
			jump_times += 1
		}
	
		break
	case BOSS_STATE.DROP:
		target_type = "air"
		sprite_index = spr_honglonglong_drop
		
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 21
		}
		else{
			image_index = floor(timer/5) mod 21 + 21
		}
		if timer == 21 * 5 - 1{
			timer = 0
			if jump_times == 1{
				state = BOSS_STATE.SKILL1
			}
			else{
				state = BOSS_STATE.SKILL2
			}
		}
		break
	case BOSS_STATE.LAUNCH:
		target_type = "air"
		sprite_index = spr_honglonglong_launch
		
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 27
		}
		else{
			image_index = floor(timer/5) mod 27 + 27
		}
		if timer == 27 * 5 - 1{
			if jump_times == 0 || jump_times == 2{
				target_pos.row = irandom_range(1,global.grid_rows-1)
				target_pos.col = irandom_range(3,6)
				var land_pos = get_world_position_from_grid(target_pos.col,target_pos.row)
				x_move_speed = (land_pos.x-10 - x)/180
				y_move_speed = (land_pos.y+33 - y)/180
				timer = 0
				state = BOSS_STATE.MOVE
			}
			else{
				target_pos.row = irandom_range(1,global.grid_rows-1)
				target_pos.col = 10
				var land_pos = get_world_position_from_grid(target_pos.col,target_pos.row)
				x_move_speed = (land_pos.x-80 - x)/180
				y_move_speed = (land_pos.y+33 - y)/180
				timer = 0
				state = BOSS_STATE.MOVE
			}
		}
		break
	case BOSS_STATE.MOVE:
		target_type = "air"
		if x_move_speed <= 0{
			sprite_index = spr_honglonglong_move_forward
		}
		else{
			sprite_index = spr_honglonglong_move_backword
		}
		
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 6
		}
		else{
			image_index = floor(timer/5) mod 6 + 6
		}
		x += x_move_speed
		y += y_move_speed
		if timer >= 180{
			timer = 0
			if jump_times == 0 || jump_times == 2{
				state = BOSS_STATE.SKILL3
			}
			else{
				state = BOSS_STATE.DROP
			}
		}
		
		break
	
	
	case BOSS_STATE.DEATH:
		sprite_index = spr_honglonglong_death
		image_index = floor(timer/5) mod image_number
		if timer >= image_number * 5{
			image_alpha -= 0.1
			image_index = image_number - 1
		}
		break
}


timer ++


// 透明度处理
if (image_alpha <= 0 && state == BOSS_STATE.DEATH) {
    instance_destroy();
}


var zombie_grid = get_grid_position_from_world(x, y);

// 更新僵尸的网格位置和深度

var base_depth = -10 - (zombie_grid.row * 45) - (zombie_grid.col * 5);
depth = base_depth - 4.5; // 僵尸比植物稍微靠后一点（在护罩外侧和咖啡豆之间）

// 保持网格位置更新

grid_col = zombie_grid.col;
grid_row = zombie_grid.row;
