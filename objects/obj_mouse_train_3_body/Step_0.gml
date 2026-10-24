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

if !instance_exists(train_head){
	instance_destroy()
	exit
}

// 死亡处理
if (hp <= 0 && state != BOSS_STATE.DEATH) {
    timer = 0;
    state = BOSS_STATE.DEATH;
    target_plant = noone;  // 清除攻击目标
}

switch state{
	case BOSS_STATE.IDLE:
		if !skill_3_style{
			sprite_index = spr_mouse_train_2_body_idle1
		}
		else{
			sprite_index = spr_mouse_train_2_body_idle2
		}
		if train_head.hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 4
		}
		else{
			image_index = floor(timer/5) mod 4 + 4
		}
		if timer >= wait_time{
			if skill_choose == 2 {
				state = BOSS_STATE.SKILL3
				timer = 0
			}
		}
		break
		
	case BOSS_STATE.APPEAR:
		if timer <= 5 * 9 - 1{
			if !skill_3_style{
				if train_dir == 0{
					sprite_index = spr_mouse_train_2_body_appear1
				}
				else{
					sprite_index = spr_mouse_train_2_body_appear2
				}
			}
			else{
				if train_dir == 0{
					sprite_index = spr_mouse_train_2_body_appear3
				}
				else{
					sprite_index = spr_mouse_train_2_body_appear4
				}
			}
			if train_head.hp > maxhp * hurt_rate{
				image_index = floor(timer/5) mod 9
			}
			else{
				image_index = floor(timer/5) mod 9 + 9
			}
		}
		else{
			if !skill_3_style{
				sprite_index = spr_mouse_train_2_body_idle1
			}
			else{
				sprite_index = spr_mouse_train_2_body_idle2
			}
			if train_head.hp > maxhp * hurt_rate{
				image_index = floor(timer/5) mod 4
			}
			else{
				image_index = floor(timer/5) mod 4 + 4
			}
		}
		
		if train_dir == 0{
			x -= 4
		}
		else{
			x += 4
		}
		
		if timer == move_time{
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
	
	case BOSS_STATE.SKILL1:
		if grid_row == 0{
			sprite_index = spr_mouse_train_3_body_skill_2_2
		}
		else if grid_row == global.grid_rows-1{
			sprite_index = spr_mouse_train_3_body_skill_2_1
		}
		else{
			sprite_index = spr_mouse_train_3_body_skill_2_3
		}
		if train_head.hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 27
		}
		else{
			image_index = floor(timer/5) mod 27 + 27
		}
		
		if timer >= 27*5 -1{
			move_time = 250 - move_time + 45
			jump_times = 0
			timer = 0
			state = BOSS_STATE.DISAPPEAR
		}
		break
	
		
	case BOSS_STATE.SKILL2:
		
		sprite_index = spr_mouse_train_2_body_idle1
		if train_head.hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 4
		}
		else{
			image_index = floor(timer/5) mod 4 + 4
		}
		
		if timer >= 10{
			move_time = 250 - move_time + 45
			jump_times = 0
			timer = 0
			state = BOSS_STATE.DISAPPEAR
		}
		break
		
	case BOSS_STATE.SKILL3:
		
		sprite_index = spr_mouse_train_2_body_idle1
		if train_head.hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 4
		}
		else{
			image_index = floor(timer/5) mod 4 + 4
		}
		
		if timer >= 1{
			move_time = 50 + 45
			jump_times = 0
			timer = 0
			state = BOSS_STATE.DISAPPEAR
		}
		break
		
	case BOSS_STATE.DISAPPEAR:
		if timer <= move_time - 9 * 5{
			if !skill_3_style{
				sprite_index = spr_mouse_train_2_body_idle1
			}
			else{
				sprite_index = spr_mouse_train_2_body_idle2
			}
			if train_head.hp > maxhp * hurt_rate{
				image_index = floor(timer/5) mod 4
			}
			else{
				image_index = floor(timer/5) mod 4 + 4
			}
		}
		else{
			if !skill_3_style{
				if train_dir == 0{
					sprite_index = spr_mouse_train_2_body_disappear1
				}
				else{
					sprite_index = spr_mouse_train_2_body_disappear2
				}
			}
			else{
				if train_dir == 0{
					sprite_index = spr_mouse_train_2_body_disappear3
				}
				else{
					sprite_index = spr_mouse_train_2_body_disappear4
				}
			}
			if train_head.hp > maxhp * hurt_rate{
				image_index = floor((timer+5*9-move_time)/5) mod 9
			}
			else{
				image_index = floor((timer+5*9-move_time)/5) mod 9 + 9
			}
		}
		
		if train_dir == 0{
			x -= 4
		}
		else{
			x += 4
		}
		
		if timer == move_time{
			image_alpha = 0
		}
		if timer == move_time{
			instance_destroy()
		}
		
		break
		
	case BOSS_STATE.SKILL4:
		sprite_index = spr_mouse_train_2_body_idle1
		if train_head.hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 4
		}
		else{
			image_index = floor(timer/5) mod 4 + 4
		}
		
		if timer >= 27*5 -1{
			move_time = 250 - move_time + 45
			jump_times = 0
			timer = 0
			state = BOSS_STATE.DISAPPEAR
		}
		break
	
	case BOSS_STATE.DEATH:
		sprite_index = spr_mouse_train_2_body_death
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

var base_depth = -401
depth = base_depth - 4.5; // 僵尸比植物稍微靠后一点（在护罩外侧和咖啡豆之间）

// 保持网格位置更新

grid_col = zombie_grid.col;
grid_row = zombie_grid.row;

