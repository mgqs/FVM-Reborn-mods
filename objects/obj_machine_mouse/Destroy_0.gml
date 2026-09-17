if can_explode{
	var inst = instance_create_depth(x,y,depth,obj_coke_bomb_explode)
	inst.sprite_index = spr_machine_mouse_explode
	audio_play_sound(snd_coke_bomb_explode,0,0)
	var _x = x;
	var _y = y;
	var _range = 200

	with (obj_card_parent) {
		
			if (point_distance(x, y, _x, _y) < _range && grid_row >= other.grid_row-1&&grid_row <= other.grid_row+1) {
		       
		            // 直接摧毁卡片
					hp -= 900
		            //instance_destroy();
		            
		        
		    }
		
	}
}