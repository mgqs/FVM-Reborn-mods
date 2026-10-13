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

var grid_pos = get_grid_position_from_world(x,y)

if flash_value > 0{
	flash_value -= 10
}

timer++

if instance_exists(train_head){
	if train_head.hp > maxhp * hurt_rate{
		image_index = floor(timer/5) mod 184
	}
	else{
		image_index = floor(timer/5) mod 184 + 184
	}
}
if timer == 57*5+2 || timer == 87*5+2 || timer == 120*5+2 || timer == 154*5+2{
	var erase_grid = erase_pos[jump_times]
	with obj_card_parent{
		if grid_col == erase_grid.col && grid_row == erase_grid.row &&
		plant_id != "player" && plant_type != "coffee" && !invincible && plant_id != "cotton_candy"{
			if hp >= max_hp{
				obj_task_manager.card_loss++
			}
			var effect_inst = instance_create_depth(x,y-30,-800,obj_coke_bomb_explode)
			effect_inst.sprite_index = spr_iron_man_mouse_laser
			instance_destroy()
		}
	}
	jump_times++
}
if timer >= 184 * 5 - 1{
	instance_destroy()
}


var zombie_grid = get_grid_position_from_world(x, y);

// 更新僵尸的网格位置和深度

var base_depth = -10 - (zombie_grid.row * 45) - (9 * 5);
depth = base_depth ; // 僵尸比植物稍微靠后一点（在护罩外侧和咖啡豆之间）

// 保持网格位置更新

grid_col = zombie_grid.col;
grid_row = zombie_grid.row;