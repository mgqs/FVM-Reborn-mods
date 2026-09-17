if not obj_package_bg.is_submenu_opened{
if type == "Player Info"{
	obj_package_bg.info_button_select = button_index
}
else if type == "Package"{
	obj_package_bg.package_button_select = button_index
	obj_package_bg.y_offset = 0
}
audio_play_sound(snd_button,0,0)
}