// Inherit the parent event
event_inherited();

if global.is_paused{
	exit
}

if state == BOSS_STATE.IDLE{
	draw_set_colour(c_white)
	draw_text(x,y,$"{damage_take}/{0.1*maxhp}")
}