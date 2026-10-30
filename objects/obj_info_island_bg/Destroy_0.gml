instance_destroy(obj_closeinfo_btn)
instance_destroy(obj_info_island_select_btn)
instance_destroy(obj_info_island_edit_menu)
instance_destroy(obj_info_island_edit_btn)
// 搜索框是独立实例，界面关了要一起销毁（leak 会让下次进来多出一个框）
if (variable_instance_exists(id, "info_search_box") && instance_exists(info_search_box)) instance_destroy(info_search_box)
if instance_exists(obj_package_bg){
	obj_package_bg.is_submenu_opened = false
}
if (instance_exists(obj_player_info_ui))
    obj_player_info_ui.menu_type = 0
if (instance_exists(obj_world_map_button))
    obj_world_map_button.world_map = 0
