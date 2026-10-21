if keyboard_check_pressed(vk_escape){
	if instance_exists(obj_mod_menu){
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
	else{
		global.gui_stack.to(room_menu)
	}
}

if current_map_id != global.map_id{
	instance_destroy(obj_levelselect_button)
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
	}

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

}
