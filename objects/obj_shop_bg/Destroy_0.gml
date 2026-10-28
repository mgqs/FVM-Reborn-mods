instance_destroy(obj_closeshop_btn)
instance_destroy(obj_shop_select_btn)
instance_destroy(obj_shop_page_btn)
instance_destroy(obj_shop_buy_btn)
// 凭证页的搜索框（2026-10-27）：关店一起销毁，别留在房间里
if (variable_instance_exists(id, "shop_search_box") && instance_exists(shop_search_box)) instance_destroy(shop_search_box)
obj_player_info_ui.menu_type = 0
obj_world_map_button.world_map = 0
panel_anim_free(id)
if (surface_exists(pg_surf)) surface_free(pg_surf)
if (surface_exists(pg_old_surf)) surface_free(pg_old_surf)
