if obj_battle.time_limit > 0{
	var minute = floor(obj_battle.time_limit/3600)
	var second = floor(obj_battle.time_limit/60) - minute * 60
	var ms = obj_battle.time_limit/60 - minute * 60 - second
	var timer_spr = spr_timer_number
	var split_index = 0
	if minute <= 0 && second <= 30{
		timer_spr = spr_timer_number_urgent
		split_index = 1
		draw_sprite_ext(timer_spr,(ms*100) div 10,room_width/2 + 150,208,1,1,0,c_white,1)
		draw_sprite_ext(timer_spr,(ms*100) mod 10,room_width/2 + 180,208,1,1,0,c_white,1)
	}
	draw_sprite_ext(timer_spr,minute div 10,room_width/2 - 100,200,1.8,1.8,0,c_white,1)
	draw_sprite_ext(timer_spr,minute mod 10,room_width/2 - 50,200,1.8,1.8,0,c_white,1)
	draw_sprite_ext(spr_timer_split,split_index,room_width/2 ,200,1.8,1.8,0,c_white,1)
	draw_sprite_ext(timer_spr,second div 10,room_width/2 + 50,200,1.8,1.8,0,c_white,1)
	draw_sprite_ext(timer_spr,second mod 10,room_width/2 + 100,200,1.8,1.8,0,c_white,1)
}