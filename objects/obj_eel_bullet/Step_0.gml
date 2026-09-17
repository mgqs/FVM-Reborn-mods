if global.is_paused{
	image_speed = 0
	exit
}
else{
	image_speed = 1
}

var target_x = get_world_position_from_grid(target_col,row).x

if x > 2200 or y > 1200 or x < -200 or y < -200{
	instance_destroy()
}

if !placed{
	x += move_speed
	image_angle += 5
	y -= cvspeed
	cvspeed -= cgravity
}

if x >= target_x - 10 && x <= target_x + 10{
	placed = true
	timer ++
	image_angle = 0
	x = target_x
	y = get_world_position_from_grid(target_col,row).y-15
	image_index = floor(timer/5) mod 10
	if timer == 8 * 5 - 1{
		var erase_col = target_col
		var erase_row = row
		// 检测前方植物
	    var plant_in_range = noone;
        
		var plant_order_list = [noone,noone,noone,noone]
		
	    // 使用碰撞检测查找攻击范围内的植物
	    with (obj_card_parent) {
				
	        // 检查是否在攻击范围内
	        if(abs(grid_col-erase_col) <= 0 && abs(grid_row-erase_row) <= 0) {
	            if !invincible && plant_type != "coffee" && plant_id != "soda_bubble"{
					if plant_id != "player"{
						hp -= 400
						event_user(2)
					}
					else{
						hp -= 100
						event_user(2)
					}
				}
	        }
	    }
	}
	if timer >= 10 * 5 - 1{
		instance_destroy()
	}
}