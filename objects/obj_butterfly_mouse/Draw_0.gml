if sprite_index == spr_butterfly_mouse || sprite_index == spr_butterfly_mouse_shield{
	draw_sprite_ext(spr_in_water_2,floor(water_effect_timer/5),x-15,y-38,1.8,1.8,0,c_white,1)
	water_effect_timer++
}
// Inherit the parent event
event_inherited();