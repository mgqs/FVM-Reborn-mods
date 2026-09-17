if global.is_paused{
	exit
}

if flash_value > 0 {
	flash_value -= 10
}

if !appear{
	var enemy_row = irandom_range(0,global.grid_rows-3)
	var enemy_pos = {}
	enemy_pos = get_world_position_from_grid(irandom_range(2,6),enemy_row)
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
		sprite_index = spr_electric_jellyfish_idle
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 16
		}
		else{
			image_index = floor(timer/5) mod 16 + 16
		}
		if timer >= wait_time{
			timer = 0
			state = BOSS_STATE.DISAPPEAR
		}
		break
		
	case BOSS_STATE.APPEAR:
		sprite_index = spr_electric_jellyfish_idle
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 16
		}
		else{
			image_index = floor(timer/5) mod 16 + 16
		}
		if timer == 16 * 5 - 1{
			timer = 0
			if skill_count == 0{
				state = BOSS_STATE.SKILL3
			}
			else if skill_count == 1{
				state = BOSS_STATE.SKILL1
			}
			else if skill_count == 2{
				state = BOSS_STATE.SKILL2
			}
			skill_count ++
			if skill_count >= 3{
				skill_count = 0
			}
			break
		}
		break
	
	case BOSS_STATE.SKILL1:
		if timer <= 48 * 5 - 1{
			sprite_index = spr_electric_jellyfish_skill_1
			if hp > maxhp * hurt_rate{
				image_index = floor(timer/5) mod 48
			}
			else{
				image_index = floor(timer/5) mod 48 + 48
			}
		}
		else if timer <= 60 + 48 * 5 - 1{
			sprite_index = spr_electric_jellyfish_move_fast
			if hp > maxhp * hurt_rate{
				image_index = floor((timer-240)/5) mod 5
			}
			else{
				image_index = floor((timer-240)/5) mod 5 + 5
			}
		}
		else if timer <= 60 + 96 * 5 - 1{
			sprite_index = spr_electric_jellyfish_skill_1
			if hp > maxhp * hurt_rate{
				image_index = floor((timer-300)/5) mod 48
			}
			else{
				image_index = floor((timer-300)/5) mod 48 + 48
			}
		}
		
		if timer == 28 * 5 + 2 || timer == 76 * 5 + 2 + 60{
			with obj_card_parent{
				if grid_col == other.grid_col-2 && grid_row == other.grid_row
				&& plant_id != "player" && plant_type != "coffee" && plant_id != "soda_bubble" && !invincible{
					instance_destroy()
					if hp >= max_hp{
						obj_task_manager.card_loss++
					}
				}
			}
		}
		if timer == 33 * 5 + 2 || timer == 71 * 5 + 2 + 60{
			with obj_card_parent{
				if grid_col == other.grid_col-3 && grid_row == other.grid_row
				&& plant_id != "player" && plant_type != "coffee" && plant_id != "soda_bubble" && !invincible{
					instance_destroy()
					if hp >= max_hp{
						obj_task_manager.card_loss++
					}
				}
			}
		}
		if timer == 39 * 5 + 2 || timer == 87 * 5 + 2 + 60{
			with obj_card_parent{
				if grid_col == other.grid_col-4 && grid_row == other.grid_row
				&& plant_id != "player" && plant_type != "coffee" && plant_id != "soda_bubble" && !invincible{
					instance_destroy()
					if hp >= max_hp{
						obj_task_manager.card_loss++
					}
				}
			}
		}
		if timer == 44 * 5 + 2 || timer == 92 * 5 + 2 + 60{
			with obj_card_parent{
				if grid_col == other.grid_col-5 && grid_row == other.grid_row
				&& plant_id != "player" && plant_type != "coffee" && plant_id != "soda_bubble" && !invincible{
					instance_destroy()
					if hp >= max_hp{
						obj_task_manager.card_loss++
					}
				}
			}
		}
		
		if timer == 48 * 5{
			var t_row = 0
			for(var i = 0 ; i < 100 ; i++){
				t_row = irandom_range(0,global.grid_rows-1)
				if t_row != grid_row{
					break
				}
			}
			var t_pos = get_world_position_from_grid(grid_col,t_row)
			x_move_speed = 0
			y_move_speed = (t_pos.y + 30 - y)/60
		}
			
		if timer >= 48*5 && timer <= 48*5+60{
			x += x_move_speed
			y += y_move_speed
		}
		
		if timer >= 60 + 96 * 5 - 1{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
		
	case BOSS_STATE.SKILL2:
		sprite_index = spr_electric_jellyfish_skill_2
		if hp > maxhp * hurt_rate{
			image_index = floor(timer /5) mod 42
		}
		else{
			image_index = floor(timer /5) mod 42 + 42
		}
		
		if timer == 1{
			// 创建已选坐标数组
			var selected_coords = [];

			// 循环直到选出3个不同的坐标
			while (array_length(selected_coords) < 3) {
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
		
		if timer == 19 * 5 + 2 || timer == 25 * 5 + 2 || timer == 32 * 5 + 2{
			var ball_inst = instance_create_depth(x,y,-800,obj_electric_jellyfish_bullet)
			ball_inst.maxhp = 1800 + 0.03*maxhp
			ball_inst.hp = 1800 + 0.03*maxhp
			ball_inst.hp_modified = true
			var ball_row = target_coord[jump_times][1]
			var ball_col = target_coord[jump_times][0]
			var ball_pos = get_world_position_from_grid(ball_col,ball_row)
			ball_inst.x_move_speed = (ball_pos.x-ball_inst.x)/90
			ball_inst.y_move_speed = (ball_pos.y+10-ball_inst.y)/90
			jump_times++
		}
		
		if timer >= 42*5-1{
			target_coord = []
			jump_times = 0
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
		
	case BOSS_STATE.SKILL3:
		
		sprite_index = spr_electric_jellyfish_skill_3
		if hp > maxhp * hurt_rate{
			image_index = floor(timer /5) mod 31
		}
		else{
			image_index = floor(timer /5) mod 31 + 31
		}
		
		if timer == 19 * 5 + 2{
			with obj_card_parent{
				if grid_col == other.grid_col && grid_row >= other.grid_row && grid_row <= other.grid_row + 2
				&& plant_id != "player" && plant_type != "coffee" && plant_id != "soda_bubble" && !invincible{
					instance_destroy()
					if hp >= max_hp{
						obj_task_manager.card_loss++
					}
				}
			}
		}
		
		if timer >= 31*5-1{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
		
	case BOSS_STATE.DISAPPEAR:
		sprite_index = spr_electric_jellyfish_move
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 8
		}
		else{
			image_index = floor(timer/5) mod 8 + 8
		}
		if timer == 1{
			var enemy_row = irandom_range(0,global.grid_rows-1)
			var enemy_pos = {}
			if skill_count == 0{
				enemy_row = irandom_range(0,global.grid_rows-3)
				enemy_pos = get_world_position_from_grid(irandom_range(2,6),enemy_row)
			}
			else if skill_count == 2{
				enemy_pos = get_world_position_from_grid(9,enemy_row)
			}
			else if skill_count == 1{
				enemy_pos = get_world_position_from_grid(9,enemy_row)
			}
			x_move_speed = (enemy_pos.x - 90 - x)/180
			y_move_speed = (enemy_pos.y + 30 - y)/180
		}
		if timer >= 1 && timer <= 180{
			x += x_move_speed
			y += y_move_speed
		}
		if timer == 180{
			timer = 0
			state = BOSS_STATE.APPEAR
		}
		break
	
	case BOSS_STATE.DEATH:
		sprite_index = spr_electric_jellyfish_death
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

