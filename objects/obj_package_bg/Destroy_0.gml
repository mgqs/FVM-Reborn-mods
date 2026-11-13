instance_destroy(obj_closepackage_btn)
instance_destroy(obj_packageselect_btn)
instance_destroy(obj_card_edit_menu)
instance_destroy(obj_gem_edit_menu)
// 「变装特效」按钮与弹窗（2026-11-13）：面板关掉时必须一起销毁，
// 否则按钮会留在屏幕上；全局互斥标志也要复位，不然下一个面板的点击会被吃掉
instance_destroy(obj_attire_fx_help)
global.attire_fx_help_open = false
global.attire_fx_help_latch = 0
obj_player_info_ui.menu_type = 0
obj_world_map_button.world_map = 0
if surface_exists(package_surface){
	surface_free(package_surface)
}
panel_anim_free(id)
