// 强制清除application_surface，避免上一房间图像残留
surface_set_target(application_surface);
draw_clear_alpha(c_black, 0); // 用透明黑色清除surface，alpha值0表示完全透明
surface_reset_target();
instance_create_depth(100,0,-2,obj_player_info_ui)

/// @type {Asset.GMObject.EventEntranceList}
var _entrance_list = instance_create_depth(0, 0, -2, EventEntranceList)
_entrance_list.set_position(600,20)
              .set_size(900, 300)

// 跨服关卡返回：先把底图还原成进入前的地图。
// 跨服关卡借用 tower_cake 的 map_id，若停在 tower_cake，本房间会按 spr_tower_cake_bg 铺底，
// 而 tower_cake 的关卡数据没有 button_x/button_y → 一个关卡按钮都不建，只剩一张空白底图。
var _cs_pending = (variable_global_exists("cross_server_return_page") && global.cross_server_return_page >= 0);
if (_cs_pending && variable_global_exists("cross_server_return_map_id") && global.cross_server_return_map_id != "") {
	global.map_id = global.cross_server_return_map_id;
	global.map_name = global.cross_server_return_map_name;
}

current_map_id = global.map_id
var map_button_array = struct_get(ds_map_find_value(global.maps_map,current_map_id),"levels_data")
var button_array_length = array_length(map_button_array)
for(var i = 0 ; i <button_array_length ; i++){
	var button_struct = map_button_array[i]
	if (!variable_struct_exists(button_struct, "button_x") || !variable_struct_exists(button_struct, "button_y")) continue;
	var inst = instance_create_depth(button_struct.button_x,button_struct.button_y,-2,obj_levelselect_button)
	inst.image_index = button_struct.button_index
	inst.target_level_id = button_struct.id
	inst.target_level_file_hard = button_struct.hard_level_file
	inst.target_level_file = button_struct.level_file
	inst.level_index = i
	inst.player_level_require = button_struct.player_level_require
	inst.pre_level_require = button_struct.pre_level_require
	inst.sprite_index = button_struct.button_spr
	if current_map_id == "longyuan" {
		inst.image_xscale = 0.56
		inst.image_yscale = 0.56
		inst.x = button_struct.button_x * room_width / sprite_get_width(spr_longyuan)
		inst.y = button_struct.button_y * room_height / sprite_get_height(spr_longyuan)
	}
	if button_struct.id == "test_level"{
		inst.image_xscale = 0.18
		inst.image_yscale = 0.18
	}
}

// 测试关卡入口（所有岛屿通用）
var test_inst = instance_create_depth(1120,56,-2,obj_levelselect_button)
test_inst.image_xscale = 0.18
test_inst.image_yscale = 0.18
test_inst.target_level_id = "test_level"
test_inst.target_level_file = "test_level.json"
test_inst.target_level_file_hard = "test_level_hard.json"
test_inst.level_index = -1
test_inst.player_level_require = 1
test_inst.pre_level_require = []
test_inst.sprite_index = spr_test_level_button


instance_create_depth(room_width-210,room_height,-1,obj_player_menu_bg)

global.laboretory_room = false

//如果玩家达到20级，且未解锁也未完成海底旋涡任务，则解锁该任务
if global.save_data.player.level >= 20{
	if !is_task_unlocked("undersea_level_0") && !is_task_complete("undersea_level_0"){
		unlock_task("undersea_level_0")
	}
}
//如果玩家达到36级，且未解锁也未完成火山遗迹任务，则解锁该任务
if global.save_data.player.level >= 36{
	if !is_task_unlocked("ruins_level_0") && !is_task_complete("ruins_level_0"){
		unlock_task("ruins_level_0")
	}
}

// 从跨服远征关卡返回时，恢复跨服远征界面。
// 跨服关卡是从本地图界面点「跨服远征」覆盖层进去的，退出时 gui_stack 弹回的就是本房间，
// 所以这里必须有和 obj_menu_manager/Create_0 同一段恢复逻辑，否则只剩一张空白底图。
if (_cs_pending) {
	var _cs_bg = instance_create_depth((room_width / 2) - 5, room_height / 2, -100, obj_cross_server_bg);
	_cs_bg.selected_page = global.cross_server_return_page;
	_cs_bg.refresh_level_buttons();
	if (instance_exists(obj_player_info_ui)) obj_player_info_ui.menu_type = 4;
	if (instance_exists(obj_world_map_button)) obj_world_map_button.world_map = 2;
	global.cross_server_return_page = -1;
}
