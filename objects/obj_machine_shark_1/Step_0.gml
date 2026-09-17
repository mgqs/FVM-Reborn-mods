if global.is_paused{
	exit
}

if flash_value > 0 {
	flash_value -= 10
}

if !appear{
	var enemy_row = irandom_range(0,global.grid_rows-1)
	var enemy_pos = {}
	enemy_pos = get_world_position_from_grid(9,global.grid_rows-1)
	x = enemy_pos.x - 90
	y = enemy_pos.y + 30
	image_alpha = 1
	timer = 0
	state = BOSS_STATE.APPEAR
	appear = true
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
		sprite_index = spr_machine_shark_1_idle
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 14
		}
		else{
			image_index = floor(timer/5) mod 14 + 14
		}
		if timer >= wait_time{
			timer = 0
			
			state = BOSS_STATE.DISAPPEAR
		}
		break
		
	case BOSS_STATE.APPEAR:
		sprite_index = spr_machine_shark_1_appear
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 6
		}
		else{
			image_index = floor(timer/5) mod 6 + 6
		}
		if timer == 6 * 5 - 1{
			timer = 0
			if skill_count == 0{
				state = BOSS_STATE.SKILL3
			}
			else if skill_count == 1{
				state = BOSS_STATE.SKILL2
			}
			else if skill_count == 2{
				state = BOSS_STATE.SKILL1
			}
			skill_count ++
			if skill_count >= 3{
				skill_count = 0
			}
			break
		}
		break
	
	case BOSS_STATE.SKILL1:
		sprite_index = spr_machine_shark_1_skill_1
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 30
		}
		else{
			image_index = floor(timer/5) mod 30 + 30
		}
		if timer == 23 * 5 + 2{
			for(var i = 0 ; i < global.grid_rows ; i++){
				var m_pos = get_world_position_from_grid(9,i)
				var m_inst = instance_create_depth(m_pos.x,m_pos.y+38,-800,obj_conch_mouse)
				m_inst.grid_row = i
			}
		}
		if timer >= 30 * 5 - 1{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
		
	case BOSS_STATE.SKILL2:
		sprite_index = spr_machine_shark_1_skill_2
		if hp > maxhp * hurt_rate{
			image_index = floor(timer /5) mod 37
		}
		else{
			image_index = floor(timer /5) mod 37 + 37
		}
		
		if timer == 1{
			// 创建已选坐标数组
			var selected_coords = [];

			// 循环直到选出2个不同的坐标
			while (array_length(selected_coords) < 2) {
			    // 生成随机坐标
			    var rand_x = irandom_range(1, 7);
			    var rand_y = irandom_range(1, global.grid_rows - 2);
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
		
		if timer == 23 * 5 + 2 || timer == 30 * 5 + 2{
			var target_p = get_world_position_from_grid(target_coord[jump_times][0],target_coord[jump_times][1])
			var missile = instance_create_depth(x-120,y-120,-800,obj_shark_1_bullet)
			missile.target_col = target_p.col
			missile.row = target_p.row
			var target_f = get_world_position_from_grid(target_p.col,target_p.row)
			missile.move_speed = (target_f.x - missile.x)/90
			missile.cvspeed = -(target_f.y - missile.y)/90
			jump_times ++
		}
		
		if timer >= 37 * 5 - 1{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.IDLE
			target_coord = []
		}
		break
		
	case BOSS_STATE.SKILL3:
		
		if timer <= 18 * 5 - 1{
			sprite_index = spr_machine_shark_1_skill_3_ready
			if hp > maxhp * hurt_rate{
				image_index = floor(timer /5) mod 18
			}
			else{
				image_index = floor(timer /5) mod 18 + 18
			}
		}
		else if timer <= 70 + 18 * 5 - 1{
			sprite_index = spr_machine_shark_1_skill_3
			if hp > maxhp * hurt_rate{
				image_index = floor((timer-90) /5) mod 8
			}
			else{
				image_index = floor((timer-90) /5) mod 8 + 8
			}
			x -= 15
		}
		else if timer <= 70 + 24 * 5 - 1{
			sprite_index = spr_machine_shark_1_disappear
			if hp > maxhp * hurt_rate{
				image_index = floor((timer-160) /5) mod 6
			}
			else{
				image_index = floor((timer-160) /5) mod 6 + 6
			}
		}
		else if timer <= 70 + 30 * 5 - 1{
			image_xscale = -1.8
			sprite_index = spr_machine_shark_1_appear
			if hp > maxhp * hurt_rate{
				image_index = floor((timer-190) /5) mod 6
			}
			else{
				image_index = floor((timer-190) /5) mod 6 + 6
			}
		}
		else if timer <= 140 + 30 * 5 - 1{
			sprite_index = spr_machine_shark_1_skill_3
			if hp > maxhp * hurt_rate{
				image_index = floor((timer-220) /5) mod 8
			}
			else{
				image_index = floor((timer-220) /5) mod 8 + 8
			}
			x += 15
		}
		else if timer <= 140 + 42 * 5 - 1{
			sprite_index = spr_machine_shark_1_skill_3_return
			if hp > maxhp * hurt_rate{
				image_index = floor((timer-290) /5) mod 12
			}
			else{
				image_index = floor((timer-290) /5) mod 12 + 12
			}
		}
		
		if timer == 70 + 24 * 5{
			y -= global.grid_cell_size_y * 6
		}
		if (timer >=18 * 5 && timer <= 70 + 18 * 5) || (timer >=70 + 30 * 5 && timer <= 140 + 30 * 5){
			with obj_card_parent{
				if grid_col == other.grid_col && grid_row == other.grid_row && plant_id != "player" && plant_type != "coffee" && plant_id != "soda_bubble" && !invincible{
					instance_destroy()
					if hp >= max_hp{
						obj_task_manager.card_loss++
					}
				}
			}
		}
		
		if timer >= 140+42*5-1{
			image_xscale = 1.8
			jump_times = 0
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
		
	case BOSS_STATE.DISAPPEAR:
		sprite_index = spr_machine_shark_1_disappear
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 6
		}
		else{
			image_index = floor(timer/5) mod 6 + 6
		}
		if timer == 6 * 5 - 1{
			image_alpha = 0
		}
		if timer == 180{
			var enemy_row = irandom_range(0,global.grid_rows-1)
			var enemy_pos = {}
			if skill_count == 1{
				enemy_pos = get_world_position_from_grid(9,3)
			}
			else if skill_count == 2{
				enemy_pos = get_world_position_from_grid(9,3)
			}
			else{
				enemy_pos = get_world_position_from_grid(9,global.grid_rows-1)
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
		sprite_index = spr_machine_shark_1_death
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

var base_depth = -10 - (zombie_grid.row * 45) - 45
depth = base_depth - 4.5; // 僵尸比植物稍微靠后一点（在护罩外侧和咖啡豆之间）

// 保持网格位置更新

grid_col = zombie_grid.col;
grid_row = zombie_grid.row;

