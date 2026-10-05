// ESC键关闭菜单
    if (keyboard_check_pressed(vk_escape)) {
		if instance_exists(obj_config_menu){
			instance_destroy(obj_config_menu)
		}
        instance_destroy();
        global.is_paused = false;
        global.show_menu = false;
    }