timer++
if keyboard_check_pressed(vk_escape){
	// 🔴 合成屋演出中（融合 / 转职 / 进化）：ESC 直接吃掉，不许退出（2026-11-11 用户口径）
	//    那三段演出都是播完那一帧才扣材料 / 提形态 / 给卡，中途关窗 = 白扣
	if (instance_exists(obj_craft_bg) && obj_craft_bg.craft_anim_lock()){ }
	else if instance_exists(obj_mod_menu){
		obj_mod_menu.close_panel()
	}
	else if instance_exists(obj_config_menu){
		panel_anim_close(obj_config_menu)
		obj_player_info_ui.menu_type = 0
	}
	else if instance_exists(obj_edit_menu){
		panel_anim_close(obj_edit_menu)
		obj_player_info_ui.menu_type = 0
	}
	else if instance_exists(obj_world_map_menu){
		panel_anim_close(obj_world_map_menu)
		obj_player_info_ui.menu_type = 0
		obj_world_map_button.world_map = 0
	}
	else if instance_exists(obj_package_bg){
		panel_anim_close(obj_package_bg)
		obj_player_info_ui.menu_type = 0
		obj_world_map_button.world_map = 0
	}
	else if instance_exists(obj_info_island_bg){
		panel_anim_close(obj_info_island_bg)
		obj_player_info_ui.menu_type = 0
		obj_world_map_button.world_map = 0
	}
	else if instance_exists(obj_shop_bg){
		panel_anim_close(obj_shop_bg)
		obj_player_info_ui.menu_type = 0
		obj_world_map_button.world_map = 0
	}
	else if instance_exists(obj_task_bg){
		panel_anim_close(obj_task_bg)
		obj_player_info_ui.menu_type = 0
		obj_world_map_button.world_map = 0
	}
	else if instance_exists(obj_craft_bg){
		panel_anim_close(obj_craft_bg)
		obj_player_info_ui.menu_type = 0
		obj_world_map_button.world_map = 0
	}
	else if instance_exists(obj_cookbook_bg){
		panel_anim_close(obj_cookbook_bg)
		obj_player_info_ui.menu_type = 0
		obj_world_map_button.world_map = 0
	}
	else if instance_exists(obj_tower_cake_bg){
		obj_player_info_ui.menu_type = 0
		obj_world_map_button.world_map = 0
		global.gui_stack.pop()
	}
	else if instance_exists(obj_gods_store_bg){
		if (!obj_gods_store_bg.is_submenu_opened){
			instance_destroy(obj_gods_store_bg)
		}
	}
	else if instance_exists(obj_gods_hall_bg){
		if (!obj_gods_hall_bg.is_submenu_opened){
			instance_destroy(obj_gods_hall_bg)
			obj_player_info_ui.menu_type = 0
			obj_world_map_button.world_map = 0
		}
	}
	else if instance_exists(obj_cross_server_bg){
		if (!obj_cross_server_bg.is_submenu_opened){
			instance_destroy(obj_cross_server_bg)
			obj_player_info_ui.menu_type = 0
			obj_world_map_button.world_map = 0
		}
	}
	else if instance_exists(obj_quit_confirm){
		// 2026-11-16 用户口径：**连按两次退出键不许直接离开游戏**，必须让「是否退出」框停在原地。
		//   原来这里写的是 game_end() —— 退出确认框还开着时再按一次就当场杀进程，
		//   玩家手快连点（右键/ESC 两次）看到的就是「没弹窗、直接退游戏」。
		//   现在交回 obj_quit_confirm 自己处理（确定 / 取消 / ESC 关闭），这里不做任何事。
	}
	else{
		instance_create_depth(room_width /2,room_height/2,-20,obj_quit_confirm)
	}
}

pre_load_texture()
if (outro_t >= 0) {
	if (!ui_anim_on(1)) outro_t = -1
	else {
		outro_t++
		if (outro_t > outro_frames) outro_t = -1
	}
}
