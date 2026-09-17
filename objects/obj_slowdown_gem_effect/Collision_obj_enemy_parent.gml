if ds_list_find_index(hitted_enemy,other.id) == -1 && row == other.grid_row{
	with other{
		if ice_timer < 4*60{
			ice_timer = 4*60
		}
	}
	ds_list_add(hitted_enemy,other.id)
}
