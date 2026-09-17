function material_registry_init(){
	global.material_pool = ds_map_create()
}

function register_material(material_id,material_info){
	ds_map_add(global.material_pool,material_id,material_info)
}

function get_material_info(material_id){
	return global.material_pool[? material_id]
}