function enemy_info_island_register_init(){
	global.enemy_info_island = ds_map_create()
	global.enemy_id_list = []
}


function register_enemy_info_island(enemy_id,info){
	global.enemy_info_island[? enemy_id] = info
	array_push(global.enemy_id_list,enemy_id)
}