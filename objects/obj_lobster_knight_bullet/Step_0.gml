if global.is_paused{
	exit
}

x += x_move_speed
y += y_move_speed

var target_pos = get_world_position_from_grid(target_col,target_row)
if y >= target_pos.y + 15{
	with obj_card_parent{
		if grid_row == other.target_row && plant_id != "player" && plant_type != "coffee" && plant_id != "soda_bubble" && !invincible{
			instance_destroy()
			if hp >= max_hp{
				obj_task_manager.card_loss++
			}
		}
	}
	var inst = instance_create_depth(target_pos.x,target_pos.y,-800,obj_coke_bomb_explode)
	inst.sprite_index = spr_lobster_knight_bullet_effect
	var effect_inst = instance_create_depth(target_pos.x,target_pos.y+10,-800,obj_lobster_knight_bullet_extend)
	effect_inst.is_parent = true
	effect_inst.col = 4
	instance_destroy()
}