draw_self()
var grid_pos = get_world_position_from_grid(col,row)
if non_undersea_card && !has_bubble{
	draw_sprite_ext(spr_drown_effect,floor(timer/5),grid_pos.x+15,grid_pos.y-15,1.8,1.8,0,c_white,1)
}