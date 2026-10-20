// 销毁事件
instance_destroy(obj_edit_menu_button);
if (instance_exists(obj_text_input)) {
    instance_destroy(obj_text_input);
}
instance_destroy(obj_save_slot_select_btn)
instance_destroy(obj_player_attire_select_btn)
instance_destroy(obj_update_checker_btn)
if (surface_exists(sw_surf)) surface_free(sw_surf)
panel_anim_free(id)
