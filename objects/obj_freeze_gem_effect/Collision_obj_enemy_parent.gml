if ds_list_find_index(hitted_enemy,other.id) == -1 && row == other.grid_row{
	with other{
		if frozen_timer < 8*60{
			frozen_timer = 8*60
		}
		if ice_timer < 20*60{
			ice_timer = 20*60
		}
	}
	ds_list_add(hitted_enemy,other.id)
}
