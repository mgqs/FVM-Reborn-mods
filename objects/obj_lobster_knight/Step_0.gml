if global.is_paused{
	exit
}

if flash_value > 0 {
	flash_value -= 10
}

if !appear{
	var enemy_row = irandom_range(0,global.grid_rows-1)
	var enemy_pos = {}
	enemy_pos = get_world_position_from_grid(9,3)
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
		sprite_index = spr_lobster_knight_idle
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 19
		}
		else{
			image_index = floor(timer/5) mod 19 + 19
		}
		if timer >= wait_time{
			timer = 0
			state = BOSS_STATE.DISAPPEAR
		}
		break
		
	case BOSS_STATE.APPEAR:
		sprite_index = spr_lobster_knight_idle
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 19
		}
		else{
			image_index = floor(timer/5) mod 19 + 19
		}
		if timer == 19 * 5 - 1{
			timer = 0
			if skill_count == 0{
				state = BOSS_STATE.SKILL2
			}
			else if skill_count == 1{
				state = BOSS_STATE.SKILL1
			}
			else if skill_count == 2{
				state = BOSS_STATE.SKILL3
			}
			skill_count ++
			if skill_count >= 3{
				skill_count = 0
			}
			break
		}
		break
	
	case BOSS_STATE.SKILL1:
		sprite_index = spr_lobster_knight_skill_1
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 44
		}
		else{
			image_index = floor(timer/5) mod 44 + 44
		}
		
		if timer == 34 * 5 + 2{
			var t_row1 = irandom_range(0,global.grid_rows-1)
			var bullet_pos1 = get_world_position_from_grid(4,t_row1)
			var missle1 = instance_create_depth(bullet_pos1.x,bullet_pos1.y-180,-800,obj_lobster_knight_bullet)
			missle1.target_col = 4
			missle1.target_row = t_row1
			missle1.y_move_speed = 15
			//var t_row2 = irandom_range(0,global.grid_rows-1)
			//for(var i = 0 ; i < 100 ; i++){
			//	if t_row2 != t_row1{
			//		break
			//	}
			//	t_row2 = irandom_range(0,global.grid_rows-1)
			//}
			//var bullet_pos2 = get_world_position_from_grid(4,t_row2)
			//var missle2 = instance_create_depth(bullet_pos2.x,bullet_pos2.y-180,-800,obj_lobster_knight_bullet)
			//missle2.target_col = 4
			//missle2.target_row = t_row2
			//missle2.y_move_speed = 15
		}
		
		if timer >= 44 * 5 - 1{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
		
	case BOSS_STATE.SKILL2:
		sprite_index = spr_lobster_knight_skill_2
		if hp > maxhp * hurt_rate{
			image_index = floor(timer /5) mod 43
		}
		else{
			image_index = floor(timer /5) mod 43 + 43
		}
		
		if timer == 1{
			with obj_card_parent{
				if plant_id == "soda_bubble"{
					array_push(other.avaliable_pos,{"row":grid_row,"col":grid_col})
				}
			}
		}
		
		if timer == 12 * 5 + 2 || timer == 18 * 5 + 2 || timer == 24 * 5 + 2 || timer == 30 * 5 + 2 || timer == 37 * 5 + 2{
			if array_length(avaliable_pos) > 0{
				var t_number = irandom_range(0,array_length(avaliable_pos)-1)
				var t_pos = avaliable_pos[t_number]
				var t_wpos = get_world_position_from_grid(t_pos.col,t_pos.row)
				with obj_card_parent{
					if plant_id == "soda_bubble" && grid_row == t_pos.row && grid_col == t_pos.col{
						instance_destroy()
						var inst = instance_create_depth(x,y,-800,obj_coke_bomb_explode)
						inst.sprite_index = spr_lobster_knight_bubble_destroy
					}
				}
				array_delete(avaliable_pos,t_number,1)
			}
		}
		
		if timer >= 43*5-1{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
		
	case BOSS_STATE.SKILL3:
		
		sprite_index = spr_lobster_knight_skill_3
		if hp > maxhp * hurt_rate{
			image_index = floor(timer /5) mod 28
		}
		else{
			image_index = floor(timer /5) mod 28 + 28
		}
		
		if timer == 1{
			skill_3_type = irandom_range(0,1)
			var enemy_pos = get_world_position_from_grid(2,0)
			if skill_3_type == 0{
				enemy_pos = get_world_position_from_grid(2,global.grid_rows-1)
			}
			x_move_speed = (enemy_pos.x - 90 - x)/70
			y_move_speed = (enemy_pos.y + 30 - y)/70
		}
		if timer == 28 * 5{
			image_xscale = -1.8
			var enemy_pos = get_world_position_from_grid(9,3)
			x_move_speed = (enemy_pos.x - 90 - x)/70
			y_move_speed = (enemy_pos.y + 30 - y)/70
		}
		if (timer >= 10 * 5 - 1 && timer <= 24 * 5 - 1) || (timer >= 38 * 5 - 1 && timer <= 52 * 5 - 1){
			x += x_move_speed
			y += y_move_speed
			with obj_card_parent{
				if grid_col == other.grid_col && grid_row == other.grid_row && plant_id != "player" && plant_type != "coffee" && plant_id != "soda_bubble" && !invincible{
					var effect_inst = instance_create_depth(x,y-30,-800,obj_coke_bomb_explode)
					effect_inst.sprite_index = spr_lobster_knight_destroy_effect
					if hp >= max_hp{
						obj_task_manager.card_loss++
					}
					instance_destroy()
				}
			}
		}
		
		if timer >= 56*5-1{
			image_xscale = 1.8
			jump_times = 0
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
		
	case BOSS_STATE.DISAPPEAR:
		sprite_index = spr_lobster_knight_move
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 27
		}
		else{
			image_index = floor(timer/5) mod 27 + 27
		}
		//if timer == 1{
		//	var enemy_row = irandom_range(0,global.grid_rows-1)
		//	var enemy_pos = {}
		//	if skill_count == 0{
		//		enemy_pos = get_world_position_from_grid(10,3)
		//	}
		//	else if skill_count == 2{
		//		enemy_pos = get_world_position_from_grid(10,enemy_row)
		//	}
		//	else if skill_count == 1{
		//		enemy_row = irandom_range(1,global.grid_rows-2)
		//		enemy_pos = get_world_position_from_grid(-1,enemy_row)
		//	}
		//	x_move_speed = (enemy_pos.x - 90 - x)/180
		//	y_move_speed = (enemy_pos.y + 30 - y)/180
		//}
		//if timer >= 1 && timer <= 180{
		//	x += x_move_speed
		//	y += y_move_speed
		//}
		if timer == 27 * 5 - 1{
			timer = 0
			state = BOSS_STATE.APPEAR
		}
		break
	
	case BOSS_STATE.DEATH:
		sprite_index = spr_lobster_knight_death
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

