event_inherited()

// 变异护盾：展开期间在身前画蜂巢屏障（11 帧循环，约 5 帧/格）
if (shield_active && hp > 0){
	draw_sprite_ext(shield_spr, floor(shield_anim / 6) mod 11,
		x + shield_dx, y + shield_dy, shield_sx, shield_sy, 0, c_white, 1)
}
