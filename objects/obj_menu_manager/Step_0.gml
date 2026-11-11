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
		game_end()
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
