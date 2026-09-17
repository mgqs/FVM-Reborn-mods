function map_registry_init(){
	global.maps_map = ds_map_create()
}

function register_map(map_id,map_data){
	ds_map_add(global.maps_map,map_id,map_data)
}