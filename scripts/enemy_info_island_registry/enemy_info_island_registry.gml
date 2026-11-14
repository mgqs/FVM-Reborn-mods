function enemy_info_island_register_init(){
	global.enemy_info_island = ds_map_create()
	global.enemy_id_list = []
}


function register_enemy_info_island(enemy_id,info){
	// 敌人情报面板是 300px 窄栏（Draw_0 的 draw_text_ext），仍按 35 字预折行；
	// 卡片面板 2026-11-14 起改由绘制端按像素折行，不再用 info_island_wrap。
	global.enemy_info_island[? enemy_id] = info_island_wrap(info)
	array_push(global.enemy_id_list,enemy_id)
}