// 兜底：精灵无效（池残留 -1 / 传入的敌人本身没有精灵，如 obj_kuileima_decoy）时回退默认灰烬图
if (!sprite_exists(sprite_index)) sprite_index = spr_mouse_ash_death;

if global.is_paused{
	image_speed = 0
	exit
}
else{
	if not special_ash{
		image_speed = 1
	}
	else{
		image_speed = 0
	}
}

// 播放长度 = 当前精灵刚好播一遍的帧数（只算一次）：round(帧数 / 帧率 * 60)
//   默认灰烬 15 帧 @10fps = 90；碎冰 15 帧 @12fps = 75（按 90 播会多播一段，尸体重新出现）
//   special_ash 是静止剪影（image_speed = 0），不参与计算，仍按 90 帧淡出
if (!ash_cycle_set){
	ash_cycle_set = true
	if (!special_ash && image_speed != 0){
		var _n  = sprite_get_number(sprite_index)
		var _sp = sprite_get_speed(sprite_index)
		if (_n > 0 && _sp > 0) life = round(_n / _sp * 60)
	}
}

if life > 0{
	life--
}
else{
	can_destroy = 1
}
if can_destroy{
	if not special_ash{
		image_index = 14
	}
	image_speed = 0
	timer--
	image_alpha = timer / 10
	if timer < 0 {
		instance_destroy()
	}
}
