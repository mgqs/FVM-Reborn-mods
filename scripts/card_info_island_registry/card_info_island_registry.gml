function info_island_register_init(){
	global.info_island = ds_map_create()
}


function register_card_info_island(card_id,info){
	global.info_island[? card_id] = info
}