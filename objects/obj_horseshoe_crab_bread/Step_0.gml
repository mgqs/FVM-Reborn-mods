if global.is_paused{
	exit
}

if shape < 1{
	drown_timer ++
	if drown_timer mod 60 == 0{
		//0转检测是否有气泡和海水
		var has_bubble = false
		var has_seawater = false
		with obj_card_parent{
			if plant_id == "soda_bubble" && grid_col == other.grid_col && grid_row == other.grid_row{
				has_bubble = true
			}
		}
		with obj_seawater{
			if col == other.grid_col && row == other.grid_row{
				has_seawater = true
			}
		}
		if !has_bubble && !has_seawater{
			hp -= 0.05*max_hp
			event_user(2)
		}
	}
}

if hp <= 0.33*max_hp{
	sprite_index = sprite_list[2]
}
else if hp <= 0.66*max_hp{
	sprite_index = sprite_list[1]
}
else{
	sprite_index = sprite_list[0]
}
event_inherited();

if is_frozen{
	exit
}

if frozen_timer > 0{
	exit
}

attack_timer++
