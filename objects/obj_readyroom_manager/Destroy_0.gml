if surface_exists(slot_surface){
	surface_free(slot_surface)
}
// 卡片搜索（2026-11-08）：离开预备房把搜索框一起销毁，别留在房间里
if (variable_instance_exists(id, "rrm_nav")) mod_search_nav_destroy(rrm_nav)
