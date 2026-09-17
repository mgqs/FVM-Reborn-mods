var inst = instance_create_depth(x+40,y+50,depth-500,obj_howitzer_bullet)
inst.damage = atk
inst.target_col = 8
if instance_exists(target_enemy){
	inst.target_col = target_enemy.grid_col
}
inst.row = grid_row

var inst2 = instance_create_depth(x+40,y+50,depth-500,obj_howitzer_bullet)
inst2.damage = atk
inst2.target_col = 8
inst2.y_offset = -120
if instance_exists(target_enemy){
	inst2.target_col = target_enemy.grid_col
}
inst2.row = grid_row