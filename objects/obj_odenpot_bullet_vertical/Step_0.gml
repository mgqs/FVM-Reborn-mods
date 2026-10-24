if global.is_paused{
	image_speed = 0
	exit
}
else{
	image_speed = 1
}
attack_timer ++
//x += move_speed
if attack_timer == 2{
	with obj_enemy_parent{
		if place_meeting(x,y,other){

			// 喷壶类（直线/旋转）可命中钻地中的地精鼠
			if hp > 0 and ((other.shape < 2 && abs(other.row - grid_row)<=4)||(other.shape >= 2 && (grid_row == other.row || abs(x-other.x)<=150))) and (can_hit(other.target_type,target_type)
				|| (variable_instance_exists(id,"mouse_id") && mouse_id == "longyuan_dijing"
					&& variable_instance_exists(id,"ly_mode") && ly_mode == "dig")){
				global.audio.play(hit_sound,0,0)
				damage_amount = other.damage
				damage_type = other.damage_type
				if (variable_instance_exists(id,"ly_dig_hittable")) ly_dig_hittable = true;
				event_user(0)
					
			}
			
		}
	}
}
if shape>=2{
	sprite_index = spr_odenpot_bullet_2
}
if x > 2200 or y > 1200 or x < 0 or y < 0{
	instance_destroy()
}