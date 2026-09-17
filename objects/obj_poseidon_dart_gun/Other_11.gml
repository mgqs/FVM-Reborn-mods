var inst = instance_create_depth(x+40,y+50,depth-500,obj_takoyaki_bullet)
inst.damage = atk
inst.move_speed = 10
inst.target_enemy = noone
inst.banding_card_obj = id
inst.row = grid_row
inst.sprite_index = spr_dart_bullet

var inst2 = instance_create_depth(x+80,y+50,depth-500,obj_takoyaki_bullet)
inst2.damage = atk
inst2.move_speed = 10
inst2.target_enemy = noone
inst2.banding_card_obj = id
inst2.row = grid_row
inst2.sprite_index = spr_dart_bullet