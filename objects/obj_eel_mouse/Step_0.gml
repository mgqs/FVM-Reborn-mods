if global.is_paused{
	exit
}
// Inherit the parent event
event_inherited();

if bomb_throwed{
	sprite_index = spr_eel_mouse
}
else{
	sprite_index = spr_eel_mouse_bomb
}

if state == ENEMY_STATE.ATTACK && !bomb_throwed && grid_col <= 8{
	for(var i = 0 ; i < grid_col;i++){
		target_col = -1
		var plant_list = ds_grid_get(global.grid_plants,i,grid_row)
		if plant_list != undefined{
			if ds_list_size(plant_list) > 0{
				for(var j = 0 ; j < ds_list_size(plant_list);j++){
					var plant_inst = plant_list[| j]
					if instance_exists(plant_inst){
						if(plant_inst.plant_type != "coffee" && plant_inst.feature_type != "dwarf"){
							target_col = i
							break
						}
					}
				}
			}
		}
		if target_col != -1{
			break
		}
	}
	if target_col == -1{
		target_col = 0
	}
	
	var bullet = instance_create_depth(x-10,y-90,-800,obj_eel_bullet)
	bullet.row = grid_row
	bullet.target_col = target_col
	bullet.damage = 400
			
	// 获取敌人当前位置和速度
	var bullet_pos = get_world_position_from_grid(target_col,grid_row)
	var enemy_x = bullet_pos.x
	var enemy_y = bullet_pos.y
    
	// 计算子弹飞行时间（基于水平距离和预设速度）
	var distance_x = enemy_x - bullet.x
	var flight_time = clamp(75 + (distance_x/1000) * 45, 75, 120)

	// 计算子弹所需的速度向量
	var total_distance_x = distance_x
	var total_distance_y = 600//enemy_y - inst.y
    
	// 抛物线运动参数计算:cite[6]
	bullet.move_speed = total_distance_x / flight_time
	bullet.cgravity = (2 * total_distance_y) / (flight_time * flight_time)
	bullet.cvspeed = (total_distance_y - 0.05 * bullet.cgravity * flight_time * flight_time) / flight_time
	
	bomb_throwed = true
}