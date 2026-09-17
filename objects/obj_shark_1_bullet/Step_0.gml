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

x += move_speed
y -= cvspeed
//cvspeed -= cgravity

if x >= target_x - 10 && x <= target_x + 10{
	var erase_col = target_col
	var erase_row = row
	
	with obj_card_parent{
		if abs(grid_col - erase_col) <= 1 && abs(grid_row - erase_row) <= 1 &&
		plant_id != "player" && plant_type != "coffee" && !invincible && plant_id != "cotton_candy" && plant_id != "soda_bubble"{
			if hp >= max_hp{
				obj_task_manager.card_loss++
			}
			instance_destroy()
		}
	}
	
	var inst_y = get_world_position_from_grid(target_col,row).y
	var inst = instance_create_depth(target_x,inst_y-15,-800,obj_coke_bomb_explode)
	inst.sprite_index = spr_machine_shark_1_bullet_effect
	
	instance_destroy()
}