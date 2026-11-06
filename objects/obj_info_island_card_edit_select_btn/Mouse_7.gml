global.audio.play(snd_button,0,0)
if btn_type == "confirm"{
	obj_info_island_bg.view_card_level = obj_info_island_edit_menu.target_current_info[? "level"]
	obj_info_island_bg.view_card_shape = obj_info_island_edit_menu.target_current_info[? "shape"]
	obj_info_island_bg.view_card_skill = obj_info_island_edit_menu.target_current_info[? "skill"]
	// 手动改过的预览值会一直保留，直到玩家点「同步背包」按钮（2026-11-06 起不再自动同步）
}
obj_info_island_bg.is_submenu_opened = false
panel_anim_close(obj_info_island_edit_menu)
