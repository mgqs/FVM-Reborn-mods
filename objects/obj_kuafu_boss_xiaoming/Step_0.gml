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

if !appear{
	skill_group = skill_group_list[irandom_range(0,array_length(skill_group_list)-1)]
	skill_group = array_shuffle(skill_group)
	var enemy_row = irandom_range(0,global.grid_rows-1)
	var enemy_pos = {}
	skill_choose = skill_group[skill_count]
	skill_count ++
	skill_change_style = irandom_range(0,1)
	if skill_choose == 2{
		if skill_change_style == 0{
			enemy_row = 5
		}
		else{
			enemy_row = 1
		}
		enemy_pos = get_world_position_from_grid(9,enemy_row)
	}
	else if skill_choose == 0{
		if skill_change_style == 0{
			enemy_row = 0
		}
		else{
			enemy_row = 1
		}
		enemy_pos = get_world_position_from_grid(10,enemy_row)
	}
	else{
		if skill_change_style == 0{
			enemy_pos = get_world_position_from_grid(8,5)
		}
		else{
			enemy_pos = get_world_position_from_grid(8,1)
		}
	}
	x = enemy_pos.x - 90
	y = enemy_pos.y + 30
	image_alpha = 1
	timer = 0
	state = BOSS_STATE.APPEAR
	appear = true
}

// 死亡处理
if (hp <= 0 && state != BOSS_STATE.DEATH) {
	global.save_data.player.gold += 2000
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
		sprite_index = spr_kuafu_boss_xiaoming_idle
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/6) mod 9
		}
		else{
			image_index = floor(timer/6) mod 9 + 9
		}
		if timer >= wait_time{
			timer = 0
			if skill_choose == 0 {
				state = BOSS_STATE.SKILL1
			}
			else if skill_choose == 1{
				state = BOSS_STATE.SKILL2
			}
			else if skill_choose == 2{
				state = BOSS_STATE.SKILL3
			}
		}
		break
		
	case BOSS_STATE.APPEAR:
		sprite_index = spr_kuafu_boss_xiaoming_appear
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/6) mod 4
		}
		else{
			image_index = floor(timer/6) mod 4
		}
		if timer == 4 * 6 - 1{
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
	
	case BOSS_STATE.SKILL1:
		sprite_index = spr_kuafu_boss_xiaoming_skill_1
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 23
		}
		else{
			image_index = floor(timer/5) mod 23 + 23
		}
		
		if timer mod (23 * 5) == 14 * 5 - 2{
			var inst = instance_create_depth(x-45,y-30,depth,obj_kuafu_boss_xiaoming_card)
			if jump_times == 1{
				inst.sprite_index = spr_kuafu_boss_xiaoming_card_2
			}
			if jump_times == 2{
				inst.sprite_index = spr_kuafu_boss_xiaoming_card_3
			}
		}
		if timer mod (23 * 5) == 23 * 5 - 1 && jump_times < 2{
			y += global.grid_cell_size_y * 2
			jump_times ++
		}
		
		if timer >= 3 * 23*5 -1{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.DISAPPEAR
		}
		break
	
		
	case BOSS_STATE.SKILL2:
		
		skill_timer++
		if jump_times == 0{
			if skill_timer <= 28 * 5 - 1{
				sprite_index = spr_kuafu_boss_xiaoming_skill_2_ready
				if hp > maxhp * hurt_rate{
					image_index = floor(skill_timer /5) mod 28
				}
				else{
					image_index = floor(skill_timer /5) mod 28 + 28
				}
			}
			else if skill_timer <= 49* 5 - 1{
				sprite_index = spr_kuafu_boss_xiaoming_skill_2
				if hp > maxhp * hurt_rate{
					image_index = floor((skill_timer-28*5) /5) mod 21
				}
				else{
					image_index = floor((skill_timer-28*5) /5) mod 21 + 21
				}
			}
			else if skill_timer <= 49*5 + 2 * 6 - 1{
				sprite_index = spr_kuafu_boss_xiaoming_disappear
				image_index = floor((skill_timer-49*5) /6) mod 2
			}
			else{
				image_alpha = 0
			}
		}
		else if jump_times == 1{
			if skill_timer <= 4 * 6 - 1{
				image_alpha = 1
				sprite_index = spr_kuafu_boss_xiaoming_appear
				image_index = floor(skill_timer /6) mod 4
			}
			else if skill_timer <= 4 * 6 + 28 * 5 - 1{
				sprite_index = spr_kuafu_boss_xiaoming_skill_2_ready
				if hp > maxhp * hurt_rate{
					image_index = floor((skill_timer-24) /5) mod 28
				}
				else{
					image_index = floor((skill_timer-24) /5) mod 28 + 28
				}
			}
			else if skill_timer <= 4 * 6 + 49* 5 - 1{
				sprite_index = spr_kuafu_boss_xiaoming_skill_2
				if hp > maxhp * hurt_rate{
					image_index = floor((skill_timer-28*5-24) /5) mod 21
				}
				else{
					image_index = floor((skill_timer-28*5-24) /5) mod 21 + 21
				}
			}
		}
		
		if jump_times == 0{
			if skill_timer == 37 * 5 - 1{
				var _fx = x - 120
				var _fy = y - 30
				var inst = instance_create_depth(_fx,_fy,-10,obj_coke_bomb_explode)
				inst.sprite_index = spr_kuafu_boss_xiaoming_stomp
				var erase_col = clamp(grid_col - 1, 0, global.grid_cols - 1)
				var erase_row = clamp(grid_row, 0, global.grid_rows - 1)

				// 变异：5*5 冰冻。格子索引 + 世界坐标双判定，避免 BOSS 悬空时整片漏判
				with (obj_card_parent) {
					var _ing = (abs(grid_col - erase_col) <= 2) && (abs(grid_row - erase_row) <= 2)
					var _inw = (abs(x - _fx) <= global.grid_cell_size_x * 2.45) && (abs(y - _fy) <= global.grid_cell_size_y * 2.45)
					if (_ing || _inw) {
						if !invincible && plant_id != "player" && plant_type != "coffee" {
							frozen_timer = 240
							ice_timer = 600
						}
					}
				}

				// 变异：留下 5*5 冰冻区域，4 秒内补种进该区域的卡片同样会被冻住
				var _ip = get_world_position_from_grid(erase_col, erase_row)
				// 深度按区域最上面一行算并再后移 40，保证整片区域都画在卡片下方
				var _idge = calculate_plant_depth(erase_col, max(erase_row - 2, 0), "normal") + 40
				var _ice = instance_create_depth(_ip.x, _ip.y, _idge, obj_kuafu_boss_ice_area)
				_ice.ice_radius = 2
				_ice.ice_life = 4 * 60
				_ice.ice_col = erase_col
				_ice.ice_row = erase_row
			}
			if skill_timer == 49*5+2*6 +120{
				skill_timer = 0
				jump_times++
				var enemy_pos = {}
	
				if skill_change_style == 0{
					enemy_pos = get_world_position_from_grid(3,1)
				}
				else{
					enemy_pos = get_world_position_from_grid(3,5)
				}
	
				x = enemy_pos.x - 90
				y = enemy_pos.y + 30
				image_alpha = 1
			}
		}
		
		else if jump_times == 1{
			if skill_timer == 24+37 * 5 - 1{
				var _fx = x - 120
				var _fy = y - 30
				var inst = instance_create_depth(_fx,_fy,-10,obj_coke_bomb_explode)
				inst.sprite_index = spr_kuafu_boss_xiaoming_stomp
				var erase_col = clamp(grid_col - 1, 0, global.grid_cols - 1)
				var erase_row = clamp(grid_row, 0, global.grid_rows - 1)

				// 变异：5*5 冰冻。格子索引 + 世界坐标双判定，避免 BOSS 悬空时整片漏判
				with (obj_card_parent) {
					var _ing = (abs(grid_col - erase_col) <= 2) && (abs(grid_row - erase_row) <= 2)
					var _inw = (abs(x - _fx) <= global.grid_cell_size_x * 2.45) && (abs(y - _fy) <= global.grid_cell_size_y * 2.45)
					if (_ing || _inw) {
						if !invincible && plant_id != "player" && plant_type != "coffee" {
							frozen_timer = 240
							ice_timer = 600
						}
					}
				}

				// 变异：留下 5*5 冰冻区域，4 秒内补种进该区域的卡片同样会被冻住
				var _ip = get_world_position_from_grid(erase_col, erase_row)
				// 深度按区域最上面一行算并再后移 40，保证整片区域都画在卡片下方
				var _idge = calculate_plant_depth(erase_col, max(erase_row - 2, 0), "normal") + 40
				var _ice = instance_create_depth(_ip.x, _ip.y, _idge, obj_kuafu_boss_ice_area)
				_ice.ice_radius = 2
				_ice.ice_life = 4 * 60
				_ice.ice_col = erase_col
				_ice.ice_row = erase_row
			}
			if skill_timer == 49*5+24{
				skill_timer = 0
				jump_times++
			}
		}
		
		if jump_times >= 2{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.DISAPPEAR
		}
		break
	case BOSS_STATE.SKILL3:
		
		sprite_index = spr_kuafu_boss_xiaoming_skill_3
		if hp > maxhp * hurt_rate{
			image_index = floor(timer /5) mod 5
		}
		else{
			image_index = floor(timer /5) mod 5
		}
		
		x += x_move_speed
		y += y_move_speed
		if skill_change_style == 0{
			if timer == 1{
				var t_pos = get_world_position_from_grid(3,4)
				x_move_speed = (t_pos.x-x)/240
				y_move_speed = (t_pos.y+30-y)/240
			}
			if timer == 241{
				var t_pos = get_world_position_from_grid(5,2)
				x_move_speed = (t_pos.x-x)/120
				y_move_speed = (t_pos.y+30-y)/120
			}
			if timer == 361{
				var t_pos = get_world_position_from_grid(1,0)
				x_move_speed = (t_pos.x-x)/240
				y_move_speed = (t_pos.y+30-y)/240
			}
		}
		else if skill_change_style == 1{
			if timer == 1{
				var t_pos = get_world_position_from_grid(3,2)
				x_move_speed = (t_pos.x-x)/240
				y_move_speed = (t_pos.y+30-y)/240
			}
			if timer == 241{
				var t_pos = get_world_position_from_grid(5,4)
				x_move_speed = (t_pos.x-x)/120
				y_move_speed = (t_pos.y+30-y)/120
			}
			if timer == 361{
				var t_pos = get_world_position_from_grid(1,6)
				x_move_speed = (t_pos.x-x)/240
				y_move_speed = (t_pos.y+30-y)/240
			}
		}
		
		with obj_card_parent{
			if grid_col == other.grid_col && grid_row == other.grid_row &&
			plant_id != "player" && plant_type != "coffee" && !invincible && plant_id != "cotton_candy"{
				if hp >= max_hp{
					obj_task_manager.card_loss++
				}
				instance_destroy()
			}
		}
		
		if timer >= 600{
			x_move_speed = 0
			y_move_speed = 0
			jump_times = 0
			timer = 0
			state = BOSS_STATE.DISAPPEAR
		}
		break
		
	case BOSS_STATE.DISAPPEAR:
		sprite_index = spr_kuafu_boss_xiaoming_disappear
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/6) mod 2
		}
		else{
			image_index = floor(timer/6) mod 2
		}
		if timer == 2 * 6 - 1{
			image_alpha = 0
		}
		if timer == 180{
			if skill_count >= array_length(skill_group){
				skill_group = skill_group_list[irandom_range(0,array_length(skill_group_list)-1)]
				skill_group = array_shuffle(skill_group)
				skill_count = 0
			}
			var enemy_row = irandom_range(0,global.grid_rows-1)
			var enemy_pos = {}
			skill_choose = skill_group[skill_count]
			skill_count ++
			skill_change_style = irandom_range(0,1)
			if skill_choose == 2{
				if skill_change_style == 0{
					enemy_row = 5
				}
				else{
					enemy_row = 1
				}
				enemy_pos = get_world_position_from_grid(9,enemy_row)
			}
			else if skill_choose == 0{
				if skill_change_style == 0{
					enemy_row = 0
				}
				else{
					enemy_row = 1
				}
				enemy_pos = get_world_position_from_grid(10,enemy_row)
			}
			else{
				if skill_change_style == 0{
					enemy_pos = get_world_position_from_grid(8,5)
				}
				else{
					enemy_pos = get_world_position_from_grid(8,1)
				}
			}
			x = enemy_pos.x - 90
			y = enemy_pos.y + 30
			image_alpha = 1
			timer = 0
			state = BOSS_STATE.APPEAR
			break
		}
		break
	
	case BOSS_STATE.DEATH:
		sprite_index = spr_kuafu_boss_xiaoming_death
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

var base_depth = -10 - (zombie_grid.row * 45) - 45;
depth = base_depth - 4.5; // 僵尸比植物稍微靠后一点（在护罩外侧和咖啡豆之间）

// 保持网格位置更新

grid_col = zombie_grid.col;
grid_row = zombie_grid.row;

