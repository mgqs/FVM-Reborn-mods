if global.is_paused{
	exit
}
timer++
if state == "appear"{
	image_index = floor(timer/5) mod 7
	if timer >= 7 * 5 - 1{
		timer = 0
		state = "move"
	}
}
if state == "move"{
	image_index = floor(timer/5) mod 10 + 7
	y += y_move
	if timer >= 120{
		timer = 0
		state = "disappear"
	}
}
if state == "disappear"{
	image_index = floor(timer/5) mod 8 + 17
	if timer >= 8*5-1{
		// 变异屎者召唤的是「变异幽灵」（灼热地域的 kf_zr_ghost，spr_kf_zr_ghost），
		// 不是原版的 obj_ghost_mouse。血量沿用原召唤物的 280，
		// 因为这一招一次召唤 10 只（原版 5 只），按 1000 血会把难度抬爆。
		var _g = instance_create_depth(x,y,depth,obj_kf_zr_ghost)
		_g.maxhp = 280
		_g.hp = 280
		instance_destroy()
	}
}