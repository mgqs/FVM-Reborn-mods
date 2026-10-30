if not obj_package_bg.is_submenu_opened{
if type == "Player Info"{
	if (obj_package_bg.info_button_select != button_index) obj_package_bg.pg_t_l = ui_anim_on(1) ? 0 : -1;
	obj_package_bg.info_button_select = button_index
}
else if type == "Package"{
	if (obj_package_bg.package_button_select != button_index) obj_package_bg.pg_t_r = ui_anim_on(1) ? 0 : -1;
	obj_package_bg.package_button_select = button_index
	obj_package_bg.y_offset_target = 0
}
global.audio.play(snd_button,0,0)
}
