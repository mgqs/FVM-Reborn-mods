image_xscale = 1;
image_yscale = 1;
button_select = 0;
current_settings = noone; // 当前设置页面的控制器
setting_buttons = []; // 存储创建的设置按钮

// 创建界面按钮
closemenu_btn = instance_create_depth(x+470, y-330, depth-1, obj_closemenu_btn);
menu_btn1 = instance_create_depth(x-360, y-245, depth-1, obj_menu_select_btn);
menu_btn2 = instance_create_depth(x-120, y-245, depth-1, obj_menu_select_btn);
menu_btn3 = instance_create_depth(x+120, y-245, depth-1, obj_menu_select_btn);
menu_btn4 = instance_create_depth(x+360, y-245, depth-1, obj_menu_select_btn);

menu_btn2.button_index = 1;
menu_btn3.button_index = 2;
menu_btn4.button_index = 3;

menu_btn2.sprite_index = spr_option_select_btn_2
menu_btn3.sprite_index = spr_option_select_btn_3
menu_btn4.sprite_index = spr_option_select_btn_4

// 添加操作设置相关变量
keybind_page = 0; // 当前快捷键设置页
keybinds_per_page = 5; // 每页显示的快捷键数量
total_keybind_pages = 0; // 总页数

// 计算总页数
total_keybind_pages = ceil(array_length(global.keybind_config) / keybinds_per_page);

/// @function create_keybind_buttons()
// 创建当前页的快捷键按钮
function create_keybind_buttons(){
	var start_index = keybind_page * keybinds_per_page;
	var end_index = min(start_index + keybinds_per_page, array_length(global.keybind_config)) - 1;

	var base_y = y - 50;
	for (var i = start_index; i <= end_index; i++) {
	    var kb = global.keybind_config[i];
	    var btn = instance_create_depth(x+270, base_y + (i - start_index) * 70, depth-1, obj_key_bind_button);
	    btn.key_name = kb.name;
	    btn.default_key = kb.default1;
	    btn.current_key = global.keybind_map[? kb.name];
	    //btn.tooltip_text = kb.tooltip;
	    btn.update_text();
	    array_push(setting_buttons, btn);
	}
}