// obj_ronghedapao_bullet Step 事件
// 运动照原版 obj_chocolatecannon_bullet：从炮口升空离场 → 换到落点列上方 → 下落 → 落地建爆炸
if global.is_paused{
	exit
}
timer++

if state == "start"{
	y -= 15;
	if y <= -200{
		var target_pos = get_world_position_from_grid(target_col,target_row)
		x = target_pos.x
		y = target_pos.y - room_height
		state = "drop"
	}
}

if state == "drop"{
	var target_pos = get_world_position_from_grid(target_col,target_row)
	y += 15
	if y >= (target_pos.y-15){
		// 落地：建爆炸特效，按形态选精灵（对象 Create 先于赋值执行，所以精灵在这里定）
		var _fx = instance_create_depth(x+15,y-15,-200,obj_ronghedapao_bullet_effect)
		_fx.blast_shape = blast_shape
		if blast_shape == 0{
			_fx.sprite_index = spr_ronghedapao_effect
		}
		else if blast_shape == 1{
			_fx.sprite_index = spr_ronghedapao_effect_1
		}
		else{
			_fx.sprite_index = spr_ronghedapao_effect_2
		}
		instance_destroy()
	}
}
