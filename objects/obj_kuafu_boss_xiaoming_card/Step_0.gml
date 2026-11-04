// Inherit the parent event
if global.is_paused{
	exit
}

// 变异：贴纸无敌——每帧回满血，任何伤害（含秒杀类）都打不掉
hp = maxhp

if hp <=0 && state != ENEMY_STATE.DEAD{
	state = ENEMY_STATE.DEAD
	timer = 0
}

if state == ENEMY_STATE.DEAD{
	image_alpha -= 0.1
	if image_alpha <= 0{
		instance_destroy()
	}
}

if state == ENEMY_STATE.ATTACK && hp > 0{
	timer = 0
	state = ENEMY_STATE.ACTING
}

event_inherited();

if state == ENEMY_STATE.ACTING && hp > 0 && state != ENEMY_STATE.DEAD{
	// 变异：贴纸无敌，必须真正摧毁 3 格卡片后才会消失
	if instance_exists(target_plant){
		var _tp = target_plant;
		var _hit = false;
		if _tp.plant_id == "player"{
			_tp.hp = 10;
			with (_tp) event_user(2);
			_hit = true;
		}
		else if !_tp.invincible && _tp.plant_id != "cotton_candy" && _tp.plant_type != "coffee"{
			if _tp.hp >= _tp.max_hp{
				obj_task_manager.card_loss ++;
			}
			with (_tp) instance_destroy();
			_hit = true;
		}
		target_plant = noone;
		timer = 0;
		if _hit{
			destroy_count ++;
			if destroy_count >= 3{
				instance_destroy();
			}
			else{
				// 还差几格：恢复前进，下一段继续找卡片
				state = ENEMY_STATE.NORMAL;
				x -= global.grid_cell_size_x * 0.6
			}
		}
		else{
			// 这一格打不动（无敌/棉花糖/咖啡）：不消失，越过继续找
			state = ENEMY_STATE.NORMAL;
			x -= global.grid_cell_size_x * 0.5
		}
	}
	else{
		target_plant = noone;
		state = ENEMY_STATE.NORMAL;
		timer = 0;
	}
}

// 没打满 3 格就快飞出场地：扑向最近的可用卡片，保证必定摧毁 3 格
var _near_edge = x < global.grid_offset_x + global.grid_cell_size_x * 0.6
if destroy_count < 3 && state == ENEMY_STATE.NORMAL && _near_edge && redirect_count < 6{
	redirect_count ++
	var _best = noone;
	var _best_d = 999999;
	with (obj_card_parent){
		if !invincible && plant_id != "player" && plant_type != "coffee" && plant_id != "cotton_candy"{
			var _d = point_distance(x, y, other.x, other.y) + abs(grid_row - other.grid_row) * 60;
			if _d < _best_d{
				_best_d = _d;
				_best = id;
			}
		}
	}
	if _best != noone{
		x = _best.x + global.grid_cell_size_x * 0.7;
		y = _best.y;
		image_angle = 90;
	}
}


