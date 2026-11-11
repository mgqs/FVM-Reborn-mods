var inst = instance_create_depth(x+50,y+50,depth-500,obj_coffeepot_bullet)
global.audio.play(snd_coffee_pot_attack,0,0)
inst.damage = atk
inst.move_speed = 0
inst.shape = 0
inst.row = grid_row
inst.start_col = grid_col
// 池化复用兜底：不显式指定就会带着 -1 进 Draw（见 obj_pool_acquire）
inst.sprite_index = spr_coffeepot_bullet