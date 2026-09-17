var inst = instance_create_depth(x+40,y+50,depth-500,obj_mightygun_bullet)
inst.damage = atk
inst.move_speed = 8
inst.row = grid_row

var inst2 = instance_create_depth(x+80,y+50,depth-500,obj_mightygun_bullet)
inst2.damage = atk
inst2.move_speed = 8
inst2.row = grid_row

var inst3 = instance_create_depth(x+120,y+50,depth-500,obj_mightygun_bullet)
inst3.damage = atk
inst3.move_speed = 8
inst3.row = grid_row

var inst4 = instance_create_depth(x,y+50,depth-500,obj_mightygun_bullet)
inst4.damage = atk
inst4.move_speed = 8
inst4.row = grid_row