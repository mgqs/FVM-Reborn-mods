var target_inst = noone
for(var i = 0;i < array_length(target_enemy);i++){
	if shape >= 1{
		target_inst = target_enemy[i]
	}
	else{
		target_inst = target_enemy[0]
	}
	if instance_exists(target_inst){
		with target_inst{
			if can_hit(other.target_type,target_type){
				if !immune_to_ash && hp > 0{
					instance_destroy()
					other.enemy_hitted = true
				}
				else if hp > 0{
					damage_amount = other.atk
					damage_type = "pierce"
					event_user(0)
				}
			}
		}
	}
	if shape == 0{
		break
	}
}
array_delete(target_enemy,0,array_length(target_enemy))
if shape == 2{
	var inst = instance_create_depth(x+global.grid_cell_size_x,y,-500,obj_stinkytofupult_bullet_effect)
	inst.grid_col = grid_col + 1
	inst.grid_row = grid_row
	inst.damage = atk
}