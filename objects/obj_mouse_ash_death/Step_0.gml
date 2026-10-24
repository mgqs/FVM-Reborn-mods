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
