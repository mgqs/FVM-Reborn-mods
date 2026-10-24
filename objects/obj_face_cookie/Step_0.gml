if global.is_paused{
	exit
}

// 注册到全局敌人表（本对象未继承父 Step，父对象的注册逻辑不会执行，需在此补注册，
// 否则不会进入 global.enemy_by_type / enemy_sx 空间索引，走新命中系统的子弹永远打不到它）
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

if flame_collect >= 500 && hp > 0 && state != "death"{
	for(var __count__ = 0 ; __count__ < 1 ; __count__++){
		var can_summon = true
		for(var hole_try_count = 0 ; hole_try_count < 100;hole_try_count++){
			can_summon = true
			var pos_x = irandom_range(3,global.grid_cols-2)
			var pos_y = irandom_range(0,global.grid_rows-1)
			var cave_pos = get_world_position_from_grid(pos_x,pos_y)
			var plant_list = ds_grid_get(global.grid_plants,cave_pos.col,cave_pos.row)
			with obj_face_cookie{
				var pos1 = get_grid_position_from_world(x,y)
				if(pos1.row == cave_pos.row && pos1.col == cave_pos.col){
					can_summon = false
				}
			}
			if ds_list_size(plant_list)>0 or global.grid_terrains[cave_pos.row][cave_pos.col].type == "obstacle"{
				can_summon = false
			}
			if can_summon{
				var inst = instance_create_depth(cave_pos.x,cave_pos.y+15,-5,obj_face_cookie)
				inst.sprite_index = sprite_index
				break
			}
		}
	}
	flame_collect = 0
}


if state == "appear"{
	image_index = floor(timer/5) mod 10
	if timer >= 10*5 - 1{
		timer = 0
		state = "idle"
	}
}
else if state == "anim"{
	if hp > maxhp * hurt_rate{
		image_index = floor(timer/5) mod 11 + 20
	}
	else{
		image_index = floor(timer/5) mod 11 + 41
	}
	with obj_flame{
		is_collected = false
		is_capture = true
		speed = 15
		if global.is_paused{
			speed = 0
		}
		direction = point_direction(x,y,other.x,other.y-125)
		if (abs(x - other.x)<=10 && abs(y - other.y+125)<=10){
			other.flame_collect += value
			instance_destroy()
		}
	}
	if timer >= 5 * 60{
		with obj_flame{
			is_capture = false
			speed = 0
		}
		timer = 0
		state = "idle"
	}
}
else if state == "idle"{
	if hp > maxhp * hurt_rate{
		image_index = floor(timer/5) mod 10 + 10
	}
	else{
		image_index = floor(timer/5) mod 10 + 31
	}
	if timer >= 8 * 60{
		timer = 0
		state = "anim"
	}
}
else if state == "death"{
	image_index = floor(timer/5) mod 15 + 52
	if timer >= 15 * 5 - 1{
		image_index = 66
		image_alpha -= 0.1
	}
}

if hp <= 0 && state != "death"{
	state = "death"
	timer = 0
}

if image_alpha <= 0 && hp <= 0{
	instance_destroy()
}


var zombie_grid = get_grid_position_from_world(x, y);

// 更新僵尸的网格位置和深度

var base_depth = -10 - (zombie_grid.row * 45) - (zombie_grid.col * 5);
depth = base_depth ; // 僵尸比植物稍微靠后一点（在护罩外侧和咖啡豆之间）

// 保持网格位置更新

grid_col = zombie_grid.col;
grid_row = zombie_grid.row;

if state != "appear"{
	//if global.grid_terrains[grid_pos.row][grid_pos.col].type != "obstacle"{
	//	current_grid_type = global.grid_terrains[grid_pos.row][grid_pos.col].type
	//	global.grid_terrains[grid_pos.row][grid_pos.col].type = "obstacle"
	//}

}