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
image_angle += 1
y -= cvspeed
cvspeed -= cgravity

if x >= target_x - 10 && x <= target_x + 10{
	var erase_col = target_col
	var erase_row = row
	with obj_card_parent{
		if(grid_col == erase_col && grid_row == erase_row && plant_id != "player"){
			if hp >= max_hp{
				obj_task_manager.card_loss++
			}
			instance_destroy()
		}
	}
	if sprite_index == spr_arno_bullet{
		var inst_y = get_world_position_from_grid(target_col,row).y
		instance_create_depth(target_x,inst_y+15,-200,obj_arno_bullet_effect)
	}
	else if sprite_index == spr_ice_residue_bullet{
		var inst = instance_create_depth(x,y,-200,obj_arno_bullet_effect)
		inst.sprite_index = spr_ice_residue_bullet_effect
	}
	instance_destroy()
}