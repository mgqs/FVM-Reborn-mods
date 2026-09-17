if other.hp > 0 and row == other.grid_row  and can_hit(target_type,other.target_type){
	var grid_pos = get_grid_position_from_world(other.x,other.y)
	var inst = instance_create_depth(grid_pos.x,grid_pos.y,0,obj_panfriedbun_bullet_effect)
	inst.damage = round(damage*splash_ratio)
	inst.grid_row = grid_pos.row
	inst.shape = shape
	if shape >= 1{
		inst.sprite_index = spr_panfriedbun_bullet_effect_2
	}
	instance_destroy()
}
	
