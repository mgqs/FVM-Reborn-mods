function enemy_info_island_register_init(){
	global.enemy_info_island = ds_map_create()
	global.enemy_id_list = []
}


function register_enemy_info_island(enemy_id,info){
	// 与卡片情报同一口径：注册即按 35 字折行，避免 BOSS 技能长段落冲出面板（见 info_island_wrap）
	global.enemy_info_island[? enemy_id] = info_island_wrap(info)
	array_push(global.enemy_id_list,enemy_id)
}