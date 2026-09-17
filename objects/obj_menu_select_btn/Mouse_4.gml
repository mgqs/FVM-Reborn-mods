if obj_config_menu.button_select != button_index{
	audio_play_sound(snd_button,0,0)
	obj_config_menu.button_select = button_index
	// 通知配置菜单切换页面
	with (obj_config_menu) {
	    button_select = other.button_index;
	    current_settings = noone; // 重置设置页面
	}
}
