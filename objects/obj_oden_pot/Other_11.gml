if shape < 2{
	var inst = instance_create_depth(x+50,y-75,depth-500,obj_coffeepot_bullet)
	global.audio.play(snd_coffee_pot_attack,0,0)
	inst.damage = atk
	inst.move_speed = 0
	inst.shape = shape
	inst.row = grid_row
	inst.start_col = grid_col
	inst.sprite_index = spr_odenpot_bullet
	if shape == 1{
		inst.sprite_index = spr_odenpot_bullet_1
	}
	
	var inst2 = instance_create_depth(x,y-95,depth-500,obj_odenpot_bullet_vertical)
	global.audio.play(snd_coffee_pot_attack,0,0)
	inst2.damage = atk
	inst2.move_speed = 0
	inst2.shape = shape
	inst2.row = grid_row
	inst2.start_col = grid_col
	inst2.sprite_index = spr_odenpot_bullet
	inst2.image_angle = 90
	if shape == 1{
		inst2.sprite_index = spr_odenpot_bullet_1
	}
	
	var inst3 = instance_create_depth(x,y-45,depth-500,obj_odenpot_bullet_vertical)
	global.audio.play(snd_coffee_pot_attack,0,0)
	inst3.damage = atk
	inst3.move_speed = 0
	inst3.shape = shape
	inst3.row = grid_row
	inst3.start_col = grid_col
	inst3.sprite_index = spr_odenpot_bullet
	inst3.image_angle = -90
	if shape == 1{
		inst3.sprite_index = spr_odenpot_bullet_1
	}
}
else{
	var inst4 = instance_create_depth(x,y-45,depth-500,obj_odenpot_bullet_vertical)
	global.audio.play(snd_coffee_pot_attack,0,0)
	inst4.damage = atk
	inst4.move_speed = 0
	inst4.shape = shape
	inst4.row = grid_row
	inst4.start_col = grid_col
	// 前三条路径都显式赋了 sprite_index，这条漏了：池里复用来的实例 sprite_index 还是 -1，
	// 第一帧画不出来（Step_0 的 shape>=2 强写会自愈，所以只是闪一下）。这里补上，与上面保持一致。
	inst4.sprite_index = spr_odenpot_bullet_2
}