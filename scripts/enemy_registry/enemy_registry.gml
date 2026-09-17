function register_enemy(enemy_id,enemy_data){
	ds_map_add(global.enemy_map,enemy_id,enemy_data)
}
function enemy_registry_init(){
	global.enemy_map = ds_map_create()
}