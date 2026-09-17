var inst = instance_create_depth(x+40,y+50,depth-500,obj_howitzer_bullet)
inst.damage = atk
inst.target_col = 8
if instance_exists(target_enemy){
	inst.target_col = target_enemy.grid_col
}
inst.row = grid_row