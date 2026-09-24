var target = find_priority_enemy()
var inst = instance_create_depth(x,y-95,depth-500,obj_tanghulu_bullet)
inst.damage = atk
inst.move_speed = 10
inst.target_enemy = target
inst.banding_card_obj = id
inst.row = grid_row
inst.bullet_shape = shape