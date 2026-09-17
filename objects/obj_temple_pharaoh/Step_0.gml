if global.is_paused{
	exit
}

if flash_value > 0 {
	flash_value -= 10
}

// 死亡处理
if (hp <= 0 && state != BOSS_STATE.DEATH) {
	global.save_data.player.gold += 1000
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
		sprite_index = spr_temple_pharaoh_idle
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 6
		}
		else{
			image_index = floor(timer/5) mod 6 + 6
		}
		if timer >= wait_time{
			timer = 0
			var i = irandom_range(1,100)
			if i <= 50{
				state = BOSS_STATE.SKILL1
			}
			else{
				state = BOSS_STATE.SKILL2
			}
		}
		break
		
	case BOSS_STATE.APPEAR:
		sprite_index = spr_temple_pharaoh_appear
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 41
		}
		else{
			image_index = floor(timer/5) mod 41 + 41
		}
		if timer == 41 * 5 - 1{
			timer = 0
			state = BOSS_STATE.IDLE
			break
		}
		break
	
	case BOSS_STATE.SKILL2:
		sprite_index = spr_temple_pharaoh_skill_2
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 44
		}
		else{
			image_index = floor(timer/5) mod 44 + 44
		}
		
		if timer == 1{
			// 创建已选坐标数组
			var selected_coords = [];

			// 循环直到选出4个不同的坐标
			while (array_length(selected_coords) < 4) {
			    // 生成随机坐标
			    var rand_x = irandom_range(0, 8);
			    var rand_y = irandom_range(0, global.grid_rows - 1);
			    var new_coord = [rand_x, rand_y];
    
			    // 检查是否已存在
			    var exists = false;
			    for (var i = 0; i < array_length(selected_coords); i++) {
			        if (selected_coords[i][0] == new_coord[0] && selected_coords[i][1] == new_coord[1]) {
			            exists = true;
			            break;
			        }
			    }
    
			    // 如果不存在则添加
			    if (!exists) {
			        array_push(selected_coords, new_coord);
			    }
			}
			target_coord = selected_coords
		}
		
		
		
		if timer == 21 * 5 + 22 * 5 * jump_times{
			var coord = target_coord[jump_times]
			var bandage_pos = get_world_position_from_grid(coord[0],coord[1])
			instance_create_depth(bandage_pos.x,bandage_pos.y+15,-200,obj_pharaoh_bandage)
			var erase_col = coord[0]
			var erase_row = coord[1]
			with obj_card_parent{
				if(grid_col == erase_col && grid_row == erase_row && plant_id != "player"){
					if hp >= max_hp{
						obj_task_manager.card_loss++
					}
					instance_destroy()
				}
			}
			jump_times++
		}
		
		if timer >= 44 * 5 * 2 - 1{
			timer = 0
			state = BOSS_STATE.DISAPPEAR
			jump_times = 0
		}
		break
		
	case BOSS_STATE.SKILL1:
		if timer <= 10 * 5  - 1{
			sprite_index = spr_temple_pharaoh_skill_1_ready
			if hp > maxhp * hurt_rate{
				image_index = floor(timer/5) mod 10
			}
			else{
				image_index = floor(timer/5) mod 10 + 10
			}
		}
		else{
			sprite_index = spr_temple_pharaoh_skill_1
			if hp > maxhp * hurt_rate{
				image_index = floor(timer/5) mod 11
			}
			else{
				image_index = floor(timer/5) mod 11 + 11
			}
		}
		
		if timer == 1{
			// 创建已选坐标数组
			var selected_coords = [];

			// 循环直到选出4个不同的坐标
			while (array_length(selected_coords) < 4) {
			    // 生成随机坐标
			    var rand_x = irandom_range(4, 8);
			    var rand_y = irandom_range(0, global.grid_rows - 1);
			    var new_coord = [rand_x, rand_y];
    
			    // 检查是否已存在
			    var exists = false;
			    for (var i = 0; i < array_length(selected_coords); i++) {
			        if (selected_coords[i][0] == new_coord[0] && selected_coords[i][1] == new_coord[1]) {
			            exists = true;
			            break;
			        }
			    }
    
			    // 如果不存在则添加
			    if (!exists) {
			        array_push(selected_coords, new_coord);
			    }
			}
			target_coord = selected_coords
		}
		
		
		
		if timer == 10 * 5  + 110 * jump_times + 1{
			var coord = target_coord[jump_times]
			var bandage_pos = get_world_position_from_grid(coord[0],coord[1])
			instance_create_depth(bandage_pos.x,bandage_pos.y-40,-200,obj_pharaoh_coffin)
			//var plant_list = ds_grid_get(global.grid_plants, coord[0],coord[1]);
			var erase_col = coord[0]
			var erase_row = coord[1]
			with obj_card_parent{
				if(grid_col == erase_col && grid_row == erase_row && plant_id != "player"){
					if hp >= max_hp{
						obj_task_manager.card_loss++
					}
					instance_destroy()
				}
			}
			jump_times++
			
		}
		if jump_times >= 4{
			jump_times = 0
			timer = 0
			skill_1_disappear = true
		}
		if skill_1_disappear{
			sprite_index = spr_temple_pharaoh_skill_1_ready
			if hp > maxhp * hurt_rate{
				image_index = 10 - floor(timer/5) mod 10
			}
			else{
				image_index = 20 - floor(timer/5) mod 10 
			}
			if timer == 10 * 5  - 1{
				timer = 0
				skill_1_disappear = false
				jump_times = 0
				state = BOSS_STATE.DISAPPEAR
			}
		}
		break
		
	case BOSS_STATE.DISAPPEAR:
		sprite_index = spr_temple_pharaoh_disappear
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 44
		}
		else{
			image_index = floor(timer/5) mod 44 + 44
		}
		if timer == 44 * 5 - 1{
			image_alpha = 0
		}
		if timer == 360{
			var enemy_row = irandom_range(0,global.grid_rows-1)
			var enemy_pos = get_world_position_from_grid(10,enemy_row)
			x = enemy_pos.x - 80
			y = enemy_pos.y + 30
			image_alpha = 1
			timer = 0
			state = BOSS_STATE.APPEAR
			break
		}
		break
	
	case BOSS_STATE.DEATH:
		sprite_index = spr_temple_pharaoh_death
		image_index = floor(timer/5) mod image_number
		if timer >= image_number * 5{
			image_alpha = 0
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

