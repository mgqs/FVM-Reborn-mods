if obj_config_menu.button_select != button_index{
	global.audio.play(snd_button,0,0)
	var _pg_old = obj_config_menu.button_select
	obj_config_menu.button_select = button_index
	// 通知配置菜单切换页面
	with (obj_config_menu) {
	    button_select = other.button_index;
	    current_settings = noone; // 重置设置页面
		pg_dir = (other.button_index > _pg_old) ? 1 : -1
		pg_t = ui_anim_on(1) ? 0 : -1
	}
}
