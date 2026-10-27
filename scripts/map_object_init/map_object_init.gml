function map_object_registry_init(){
	global.map_object_pool = ds_map_create()
}

function register_map_object(map_obj_id,map_obj_data){
	ds_map_add(global.map_object_pool,map_obj_id,map_obj_data)
}

function get_map_object_data(map_obj_id){
	return ds_map_find_value(global.map_object_pool,map_obj_id)
}

function map_object_init(){
	map_object_registry_init()
	register_map_object("obstacle",{"name":"障碍物","_obj":obj_obstacle,"x_offset":0,"y_offset":-35})
	register_map_object("wind_tunnel",{"name":"风洞","_obj":obj_wind_tunnel,"x_offset":5,"y_offset":-35})
	register_map_object("lava",{"name":"岩浆","_obj":obj_lava,"x_offset":0,"y_offset":-35})
	register_map_object("seawater",{"name":"海水","_obj":obj_seawater,"x_offset":0,"y_offset":-35})
	// 龙柱：种类由 longzhu_kind 字段指定（cheng/lv/huang/lv2）
	register_map_object("ly_longzhu_1",{"name":"龙柱·懒惰(橙)","_obj":obj_longzhu,"x_offset":0,"y_offset":-35,"longzhu_kind":"cheng"})
	register_map_object("ly_longzhu_2",{"name":"龙柱·暴食(绿)","_obj":obj_longzhu,"x_offset":0,"y_offset":-35,"longzhu_kind":"lv"})
	register_map_object("ly_longzhu_3",{"name":"龙柱·贪婪(黄)","_obj":obj_longzhu,"x_offset":0,"y_offset":-35,"longzhu_kind":"huang"})
	register_map_object("ly_longzhu_4",{"name":"龙柱·傲慢(青绿)","_obj":obj_longzhu,"x_offset":0,"y_offset":-35,"longzhu_kind":"lv2"})
	// 奶盖桥（longyuan_6）岩浆轨道：初始显示 obj_ludi 播放 spr_ludi_idel，
	// 触发后由 obj_ludi.Destroy 切换为 obstacle 地形并生成 obj_lava。
	// ludi_track: 1 = 红轨道（小兵第 3 波触发） / 2 = 黄轨道（首个 BOSS 波触发）
	register_map_object("ly_ludi_track_1",{"name":"岩浆轨道·陆地1","_obj":obj_ludi,"x_offset":0,"y_offset":-35,"ludi_track":1})
	register_map_object("ly_ludi_track_2",{"name":"岩浆轨道·陆地2","_obj":obj_ludi,"x_offset":0,"y_offset":-35,"ludi_track":2})
}