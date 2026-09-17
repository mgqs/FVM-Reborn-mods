function boss_registry_init(){
	global.boss_list = ds_map_create()
}
function register_boss(boss_id,data){
	ds_map_add(global.boss_list,boss_id,data)
}