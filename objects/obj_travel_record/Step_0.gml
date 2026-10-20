if global.is_paused{
	exit
}

// This boss replaces the enemy parent Step event, so keep it in the shared bullet index.
if (!enemy_registered || enemy_registered_type != target_type) {
	if (enemy_registered) {
		var _old_list = global.enemy_by_type[$ enemy_registered_type];
		var _old_idx = array_get_index(_old_list, id);
		if (_old_idx != -1) array_delete(_old_list, _old_idx, 1);
	}
	if (!variable_global_exists("enemy_by_type")) global.enemy_by_type = {};
	if (!variable_struct_exists(global.enemy_by_type, target_type)) {
		global.enemy_by_type[$ target_type] = [];
	}
	array_push(global.enemy_by_type[$ target_type], id);
	enemy_registered = true;
	enemy_registered_type = target_type;
}

if flash_value > 0 {
	flash_value -= 10
}

// 死亡处理
if (hp <= 0 && state != BOSS_STATE.DEATH) {
	global.save_data.player.gold += 1500
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
		//target_type = "normal"
		if target_type == "air"{
			sprite_index = spr_travel_record_idle_2
		}
		else{
			sprite_index = spr_travel_record_idle_1
		}
		if target_type == "air"{
			if hp > maxhp * hurt_rate{
				image_index = floor(timer/5) mod 11
			}
			else{
				image_index = floor(timer/5) mod 11 + 11
			}
		}
		else{
			if hp > maxhp * hurt_rate{
				image_index = floor(timer/5) mod 10
			}
			else{
				image_index = floor(timer/5) mod 10 + 10
			}
		}
		if timer >= wait_time{
			timer = 0
			state = BOSS_STATE.LAUNCH
			wait_time = 300
		}
		break
		
	case BOSS_STATE.APPEAR:
		target_type = "normal"
		sprite_index = spr_travel_record_appear
		
		image_index = floor(timer/5) mod 40
		
		if timer == 40 * 5 - 1{
			timer = 0
			state = BOSS_STATE.IDLE
			break
		}
		break
	
	case BOSS_STATE.SKILL1:
		target_type = "normal"
		sprite_index = spr_travel_record_skill_1

		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 53
		}
		else{
			image_index = floor(timer/5) mod 53 + 53
		}
		
		if timer == 2{
			awake_card_id_list = []
			with obj_card_parent{
				if state != CARD_STATE.SLEEP{
					state = CARD_STATE.SLEEP
					array_push(other.awake_card_id_list,id)
				}
			}
		}
		if timer >= 53*5-1{
			with obj_card_parent{
				if array_get_index(other.awake_card_id_list,id) != -1{
					awake_buff_timer += 5
				}
			}
			awake_card_id_list = []
			jump_times += 1
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
		
	case BOSS_STATE.SKILL2:
		target_type = "normal"
		sprite_index = spr_travel_record_skill_2
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 46
		}
		else{
			image_index = floor(timer/5) mod 46 + 46
		}
		
		if timer == 5 * 5 - 1{
			var inst = instance_create_depth(x+80,y-120,depth+1,obj_coke_bomb_explode)
			inst.sprite_index = spr_travel_recoed_line
		}
		if timer == 12 * 5 + 2{
			for(var i = 0 ; i < 3 ; i++){
				var erase_row = skill_2_pos[i][0]
				var erase_col = skill_2_pos[i][1]
				with obj_card_parent{
					if grid_col == erase_col && grid_row == erase_row &&
					plant_id != "player" && plant_type != "coffee" && !invincible && plant_id != "cotton_candy"{
						if hp >= max_hp{
							obj_task_manager.card_loss++
						}
						instance_destroy()
					}
				}
			}
		}
		if timer == 29 * 5 + 2{
			for(var i = 3 ; i < 4 ; i++){
				var erase_row = skill_2_pos[i][0]
				var erase_col = skill_2_pos[i][1]
				with obj_card_parent{
					if grid_col == erase_col && grid_row == erase_row &&
					plant_id != "player" && plant_type != "coffee" && !invincible && plant_id != "cotton_candy"{
						if hp >= max_hp{
							obj_task_manager.card_loss++
						}
						instance_destroy()
					}
				}
			}
		}
		if timer == 38 * 5 + 2{
			for(var i = 4 ; i < 6 ; i++){
				var erase_row = skill_2_pos[i][0]
				var erase_col = skill_2_pos[i][1]
				with obj_card_parent{
					if grid_col == erase_col && grid_row == erase_row &&
					plant_id != "player" && plant_type != "coffee" && !invincible && plant_id != "cotton_candy"{
						if hp >= max_hp{
							obj_task_manager.card_loss++
						}
						instance_destroy()
					}
				}
			}
		}
		
		if timer == 46 * 5 - 1{
			ds_list_destroy(avaliable_pos)
			avaliable_pos = ds_list_create()
			timer = 0
			state = BOSS_STATE.IDLE
			jump_times = 0
			var new_pos = get_world_position_from_grid(2,5)
			x = new_pos.x - 90
			y = new_pos.y + 33
			target_type = "normal"
		}
		break
		
	case BOSS_STATE.SKILL3:
		target_type = "normal"
		sprite_index = spr_travel_record_skill_3
		
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 31
		}
		else{
			image_index = floor(timer/5) mod 31 + 31
		}
		
		if timer == 23 * 5 + 2{
			instance_create_depth(x-210,y-35,-800,obj_travel_record_moon)
		}
		
		if timer >= 31*5-1{
			timer = 0
			state = BOSS_STATE.IDLE
			jump_times += 1
			target_type = "air"
		}
	
		break	
	
	case BOSS_STATE.DISAPPEAR:
		sprite_index = spr_travel_record_idle_1
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 10
		}
		else{
			image_index = floor(timer/5) mod 10 + 10
		}
		if timer == 10 * 5 - 1{
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
	
	case BOSS_STATE.DROP:
		target_type = "air"
		if jump_times == 1 || jump_times == 2{
			sprite_index = spr_travel_record_drop
		
			if hp > maxhp * hurt_rate{
				image_index = floor(timer/5) mod 10
			}
			else{
				image_index = floor(timer/5) mod 10 + 10
			}
		}
		else{
			timer = 50
		}
		if timer >= 10 * 5 - 1{
			timer = 0
			if jump_times == 0{
				state = BOSS_STATE.SKILL1
			}
			else if jump_times == 1{
				state = BOSS_STATE.SKILL3
			}
			else{
				state = BOSS_STATE.SKILL2
			}
		}
		break
	case BOSS_STATE.LAUNCH:
		target_type = "air"
		if jump_times == 1 || jump_times == 0{
			sprite_index = spr_travel_record_launch
		
			if hp > maxhp * hurt_rate{
				image_index = floor(timer/5) mod 11
			}
			else{
				image_index = floor(timer/5) mod 11 + 11
			}
		}
		else{
			timer = 55
		}
		if timer >= 11 * 5 - 1{
			if jump_times == 0{
				target_pos.row = irandom_range(1,global.grid_rows-1)
				target_pos.col = 1
			}
			else if jump_times == 1{
				target_pos.row = 3
				target_pos.col = 7
			}
			else if jump_times == 2{
				target_pos.row = 2
				target_pos.col = 7
			}
			var land_pos = get_world_position_from_grid(target_pos.col,target_pos.row)
			x_move_speed = (land_pos.x-90 - x)/120
			y_move_speed = (land_pos.y+33 - y)/120
			timer = 0
			state = BOSS_STATE.MOVE
		}
		break
	case BOSS_STATE.MOVE:
		target_type = "air"
		sprite_index = spr_travel_record_move
		
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 8
		}
		else{
			image_index = floor(timer/5) mod 8 + 8
		}
		x += x_move_speed
		y += y_move_speed
		if timer >= 120{
			timer = 0
			state = BOSS_STATE.DROP
			if jump_times == 0{
				image_xscale = -1.8
			}
			if jump_times == 1{
				image_xscale = 1.8
			}
		}
		
		break
	
	
	case BOSS_STATE.DEATH:
		if target_type == "air"{
			sprite_index = spr_travel_record_death_1
		}
		else{
			sprite_index = spr_travel_record_death_2
		}
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

